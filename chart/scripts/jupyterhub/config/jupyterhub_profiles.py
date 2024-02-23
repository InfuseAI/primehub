import asyncio
import json
import os
import time
import traceback
import urllib
from datetime import datetime
import re


import jupyterhub.handlers
from jinja2 import Environment, FileSystemLoader
from jupyterhub.handlers import BaseHandler, LoginHandler, LogoutHandler
from jupyterhub.scopes import needs_scope
from jupyterhub.utils import url_path_join
from kubespawner import KubeSpawner
from kubespawner.clients import shared_client
from kubespawner.reflector import NamespacedResourceReflector
from oauthenticator.generic import GenericOAuthenticator
from oauthenticator.oauth2 import OAuthCallbackHandler, OAuthLoginHandler
from tornado import gen, httpclient, web
from tornado.auth import OAuth2Mixin
from traitlets import default

from z2jh import get_config


# MONKEY-PATCH :: BaseHandler [START]
# set cookie every time
# https://github.com/InfuseAI/jupyterhub/commit/65b63e757e6c6197173c50d82404fb6b46a4a488
def monkey_patched_set_login_cookie(self, user):
    self.log.debug("set_hub_cookie for user[%s]" % user)
    self.original_set_login_cookie(user)
    # create and set a new cookie token for the hub
    self.set_hub_cookie(user)


jupyterhub.handlers.BaseHandler.original_set_login_cookie = jupyterhub.handlers.BaseHandler.set_login_cookie
jupyterhub.handlers.BaseHandler.set_login_cookie = monkey_patched_set_login_cookie
print(f"apply monkey-patch to jupyterhub.handlers.BaseHandler.set_login_cookie "
      f"=> {jupyterhub.handlers.BaseHandler.set_login_cookie}")
# MONKEY-PATCH :: BaseHandler [END]

# MONKEY-PATCH :: MyAdminHandler [START]
import jupyterhub.handlers.pages

"""Basic class to manage pagination utils."""
# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
from traitlets import default
from traitlets import Integer
from traitlets import observe
from traitlets import Unicode
from traitlets import validate
from traitlets.config import Configurable


class Pagination(Configurable):

    # configurable options
    default_per_page = Integer(
        100,
        config=True,
        help="Default number of entries per page for paginated results.",
    )

    max_per_page = Integer(
        250,
        config=True,
        help="Maximum number of entries per page for paginated results.",
    )

    # state variables
    url = Unicode("")
    page = Integer(1)
    per_page = Integer(1, min=1)

    @default("per_page")
    def _default_per_page(self):
        return self.default_per_page

    @validate("per_page")
    def _limit_per_page(self, proposal):
        if self.max_per_page and proposal.value > self.max_per_page:
            return self.max_per_page
        if proposal.value <= 1:
            return 1
        return proposal.value

    @observe("max_per_page")
    def _apply_max(self, change):
        if change.new:
            self.per_page = min(change.new, self.per_page)

    total = Integer(0)

    total_pages = Integer(0)

    @default("total_pages")
    def _calculate_total_pages(self):
        total_pages = self.total // self.per_page
        if self.total % self.per_page:
            # there's a remainder, add 1
            total_pages += 1
        return total_pages

    @observe("per_page", "total")
    def _update_total_pages(self, change):
        """Update total_pages when per_page or total is changed"""
        self.total_pages = self._calculate_total_pages()

    separator = Unicode("...")

    def get_page_args(self, handler):
        """
        This method gets the arguments used in the webpage to configurate the pagination
        In case of no arguments, it uses the default values from this class

        Returns:
          - page: The page requested for paginating or the default value (1)
          - per_page: The number of items to return in this page. No more than max_per_page
          - offset: The offset to consider when managing pagination via the ORM
        """
        page = handler.get_argument("page", 1)
        per_page = handler.get_argument("per_page", self.default_per_page)
        try:
            self.per_page = int(per_page)
        except Exception:
            self.per_page = self.default_per_page

        try:
            self.page = int(page)
            if self.page < 1:
                self.page = 1
        except Exception:
            self.page = 1

        return self.page, self.per_page, self.per_page * (self.page - 1)

    @property
    def info(self):
        """Get the pagination information."""
        start = 1 + (self.page - 1) * self.per_page
        end = start + self.per_page - 1
        if end > self.total:
            end = self.total

        if start > self.total:
            start = self.total

        return {'total': self.total, 'start': start, 'end': end}

    def calculate_pages_window(self):
        """Calculates the set of pages to render later in links() method.
        It returns the list of pages to render via links for the pagination
        By default, as we've observed in other applications, we're going to render
        only a finite and predefined number of pages, avoiding visual fatigue related
        to a long list of pages. By default, we render 7 pages plus some inactive links with the characters '...'
        to point out that there are other pages that aren't explicitly rendered.
        The primary way of work is to provide current webpage and 5 next pages, the last 2 ones
        (in case the current page + 5 does not overflow the total lenght of pages) and the first one for reference.
        """

        before_page = 2
        after_page = 2
        window_size = before_page + after_page + 1

        # Add 1 to total_pages since our starting page is 1 and not 0
        last_page = self.total_pages

        pages = []

        # will default window + start, end fit without truncation?
        if self.total_pages > window_size + 2:
            if self.page - before_page > 1:
                # before_page will not reach page 1
                pages.append(1)
                if self.page - before_page > 2:
                    # before_page will not reach page 2, need separator
                    pages.append(self.separator)

            pages.extend(range(max(1, self.page - before_page), self.page))
            # we now have up to but not including self.page

            if self.page + after_page + 1 >= last_page:
                # after_page gets us to the end
                pages.extend(range(self.page, last_page + 1))
            else:
                # add full after_page entries
                pages.extend(range(self.page, self.page + after_page + 1))
                # add separator *if* this doesn't get to last page - 1
                if self.page + after_page < last_page - 1:
                    pages.append(self.separator)
                pages.append(last_page)

            return pages

        else:
            # everything will fit, nothing to think about
            # always return at least one page
            return list(range(1, last_page + 1)) or [1]

    @property
    def links(self):
        """Get the links for the pagination.
        Getting the input from calculate_pages_window(), generates the HTML code
        for the pages to render, plus the arrows to go onwards and backwards (if needed).
        """
        if self.total_pages == 1:
            return []

        pages_to_render = self.calculate_pages_window()

        links = ['<nav>']
        links.append('<ul class="pagination">')

        if self.page > 1:
            prev_page = self.page - 1
            links.append(
                '<li><a href="?page={prev_page}">«</a></li>'.format(prev_page=prev_page)
            )
        else:
            links.append(
                '<li class="disabled"><span><span aria-hidden="true">«</span></span></li>'
            )

        for page in list(pages_to_render):
            if page == self.page:
                links.append(
                    '<li class="active"><span>{page}<span class="sr-only">(current)</span></span></li>'.format(
                        page=page
                    )
                )
            elif page == self.separator:
                links.append(
                    '<li class="disabled"><span> <span aria-hidden="true">{separator}</span></span></li>'.format(
                        separator=self.separator
                    )
                )
            else:
                links.append(
                    '<li><a href="?page={page}">{page}</a></li>'.format(page=page)
                )

        if self.page >= 1 and self.page < self.total_pages:
            next_page = self.page + 1
            links.append(
                '<li><a href="?page={next_page}">»</a></li>'.format(next_page=next_page)
            )
        else:
            links.append(
                '<li class="disabled"><span><span aria-hidden="true">»</span></span></li>'
            )

        links.append('</ul>')
        links.append('</nav>')

        return ''.join(links)

class MyAdminHandler(BaseHandler):
    """Render the admin page."""

    @web.authenticated
    # stacked decorators: all scopes must be present
    # note: keep in sync with admin link condition in page.html
    @needs_scope('admin-ui')
    async def get(self):
        from jupyterhub import orm
        pagination = Pagination(url=self.request.uri, config=self.config)
        page, per_page, offset = pagination.get_page_args(self)

        available = {'name', 'admin', 'running', 'last_activity'}
        default_sort = ['admin', 'name']
        mapping = {'running': orm.Spawner.server_id}
        for name in available:
            if name not in mapping:
                table = orm.User if name != "last_activity" else orm.Spawner
                mapping[name] = getattr(table, name)

        default_order = {
            'name': 'asc',
            'last_activity': 'desc',
            'admin': 'desc',
            'running': 'desc',
        }

        sorts = self.get_arguments('sort') or default_sort
        orders = self.get_arguments('order')

        for bad in set(sorts).difference(available):
            self.log.warning("ignoring invalid sort: %r", bad)
            sorts.remove(bad)
        for bad in set(orders).difference({'asc', 'desc'}):
            self.log.warning("ignoring invalid order: %r", bad)
            orders.remove(bad)

        # add default sort as secondary
        for s in default_sort:
            if s not in sorts:
                sorts.append(s)
        if len(orders) < len(sorts):
            for col in sorts[len(orders) :]:
                orders.append(default_order[col])
        else:
            orders = orders[: len(sorts)]

        # this could be one incomprehensible nested list comprehension
        # get User columns
        cols = [mapping[c] for c in sorts]
        # get User.col.desc() order objects
        ordered = [getattr(c, o)() for c, o in zip(cols, orders)]

        query = self.db.query(orm.User).outerjoin(orm.Spawner).distinct(orm.User.id)
        subquery = query.subquery("users")
        users = (
            self.db.query(orm.User)
            .select_entity_from(subquery)
            .outerjoin(orm.Spawner)
            .order_by(*ordered)
            .limit(per_page)
            .offset(offset)
        )

        users = [self._user_from_orm(u) for u in users]

        running = []
        for u in users:
            running.extend(s for s in u.spawners.values() if s.active)

        pagination.total = query.count()

        auth_state = await self.current_user.get_auth_state()
        html = await self.render_template(
            'admin.html',
            current_user=self.current_user,
            auth_state=auth_state,
            admin_access=self.settings.get('admin_access', False),
            users=users,
            running=running,
            sort={s: o for s, o in zip(sorts, orders)},
            allow_named_servers=self.allow_named_servers,
            named_server_limit_per_user=self.named_server_limit_per_user,
            server_version='{} {}'.format(jupyterhub.__version__, self.version_hash),
            pagination=pagination,
        )
        self.finish(html)


jupyterhub.handlers.pages.AdminHandler.get = MyAdminHandler.get
print(f"apply monkey-patch to jupyterhub.handlers.pages.AdminHandler.get")
# MONKEY-PATCH :: MyAdminHandler [END]

try:
    # it is for local development
    from primehub_utils import *
except Exception:
    pass

primehub_version = get_primehub_config('version')
keycloak_url = get_primehub_config('keycloak.url')
keycloak_app_url = get_primehub_config('keycloak.appUrl')
realm = get_primehub_config('keycloak.realm')

oidc_client_secret = get_primehub_config('clientSecret')
if not oidc_client_secret:
    oidc_client_secret = os.environ.get('KC_CLIENT_SECRET', '')
scope_required = get_primehub_config('scopeRequired')
role_prefix = get_primehub_config('keycloak.rolePrefix', "")
base_url = get_primehub_config('baseUrl', "/")
enable_feature_ssh_server = get_primehub_config('sshServer.enabled', False)
enable_telemetry = get_primehub_config('telemetry.enabled', False)
jupyterhub_template_path = '/etc/jupyterhub/templates'
start_notebook_config = get_primehub_config('startNotebookConfigMap')
template_loader = Environment(
    loader=FileSystemLoader(jupyterhub_template_path))

if role_prefix:
    role_prefix += ':'

graphql_endpoint = get_primehub_config('graphqlEndpoint')
graphql_secret = os.environ.get('GRAPHQL_SHARED_SECRET', get_primehub_config('graphqlSecret'))
fs_group_id = get_config('singleuser.fsGid')

autoscaling_enabled = get_config('scheduling.userScheduler.enabled')

phfs_enabled = get_primehub_config('phfsEnabled', False)
phfs_pvc = get_primehub_config('phfsPVC', '')

grantSudo = get_primehub_config('grantSudo', True)

# Uncomment below to setup prefix (e.g. Bearer) for API key, if needed
# configuration.api_key_prefix['authorization'] = 'Bearer'

BACKEND_API_UNAVAILABLE = 'API_UNAVAILABLE'
GRAPHQL_LAUNCH_CONTEXT_QUERY = '''query ($id: ID!) {
                    system { defaultUserVolumeCapacity }
                    user (where: { id: $id }) { id username isAdmin volumeCapacity predefinedEnvs
                    groups {
                            id
                            name
                            displayName
                            enabledSharedVolume
                            sharedVolumeCapacity
                            homeSymlink
                            launchGroupOnly
                            quotaCpu
                            quotaGpu
                            quotaMemory
                            projectQuotaCpu
                            projectQuotaGpu
                            projectQuotaMemory
                            instanceTypes { name displayName description spec global }
                            images { name displayName description isReady spec global }
                            datasets { name displayName description spec global writable mountRoot homeSymlink launchGroupOnly }
                            mlflow { trackingUri uiUrl trackingEnvs { name value } artifactEnvs { name value }}
                        }
                } }'''
GRAPHQL_SEND_TELEMETRY_MUTATION = '''mutation ($data: NotebookNotifyEventInput!) {
                    notifyNotebookEvent (data: $data)
                }'''
GRAPHQL_UDPATE_USER_PREDEFINED_ENVS_MUTATION = '''mutation ($id: ID!, $predefinedEnvs: String!) {
    updateUser(
        data: { predefinedEnvs: $predefinedEnvs }
        where: { id: $id }
    ) {
        id
    }
}'''


def _get_headers():
    return {"Content-Type": "application/json", "Authorization": f"Bearer {graphql_secret}"}


async def update_user_predefined_envs(user_id, predefined_envs):
    data = {
        "query": GRAPHQL_UDPATE_USER_PREDEFINED_ENVS_MUTATION,
        "variables": {"id": user_id, "predefinedEnvs": json.dumps(predefined_envs)},
    }
    client = httpclient.AsyncHTTPClient(max_clients=64)
    response = await client.fetch(
        graphql_endpoint, method="POST", headers=_get_headers(), body=json.dumps(data)
    )
    result = json.loads(response.body.decode())
    if 'errors' in result:
        print(f"update_user_predefined_envs error: {result['errors']}")


async def fetch_context(user_id):
    data = {"query": GRAPHQL_LAUNCH_CONTEXT_QUERY, "variables": {"id": user_id}}
    client = httpclient.AsyncHTTPClient(max_clients=64)
    response = await client.fetch(
        graphql_endpoint, method="POST", headers=_get_headers(), body=json.dumps(data)
    )
    result = json.loads(response.body.decode())

    # Code: `API_UNAVAILABLE` if kube-apiserver is down.
    if "errors" in result:
        raise Exception(BACKEND_API_UNAVAILABLE)

    return result.get("data", {})


async def send_telemetry(traits):
    if not enable_telemetry:
        return

    data = {'query': GRAPHQL_SEND_TELEMETRY_MUTATION,
            'variables': {'data': traits}}
    client = httpclient.AsyncHTTPClient(max_clients=64)
    response = await client.fetch(graphql_endpoint,
                                  method='POST',
                                  headers=_get_headers(),
                                  body=json.dumps(data))
    result = json.loads(response.body.decode())

    # Code: `API_UNAVAILABLE` if kube-apiserver is down.
    if 'errors' in result:
        raise Exception(BACKEND_API_UNAVAILABLE)


class PrimehubOidcMixin(OAuth2Mixin):
    _OAUTH_AUTHORIZE_URL = '%s/realms/%s/protocol/openid-connect/auth' % (keycloak_app_url, realm)
    _OAUTH_ACCESS_TOKEN_URL = '%s/realms/%s/protocol/openid-connect/token' % (keycloak_url, realm)


class OIDCLoginHandler(OAuthLoginHandler, PrimehubOidcMixin):
    pass


class OIDCLogoutHandler(LogoutHandler):
    kc_logout_url = '%s/realms/%s/protocol/openid-connect/logout' % (
        keycloak_app_url, realm)

    async def get(self):
        await self.default_handle_logout()
        await self.handle_logout()
        # redirect to keycloak logout url and redirect back with kc=true parameters
        # then proceed with the original logout method.
        logout_kc = self.get_argument('kc', '')
        if logout_kc != 'true':
            logout_url = self.request.full_url() + '?kc=true'
            self.redirect(self.kc_logout_url + '?' +
                          urllib.parse.urlencode({'redirect_uri': logout_url}))
        else:
            await super().get()


class OIDCAuthenticator(GenericOAuthenticator):
    client_id = 'jupyterhub'
    client_secret = oidc_client_secret
    token_url = '%s/realms/%s/protocol/openid-connect/token' % (
        keycloak_url, realm)
    userdata_url = '%s/realms/%s/protocol/openid-connect/userinfo' % (
        keycloak_url, realm)
    userdata_method = 'GET'
    userdata_params = {'state': 'state'}
    username_key = 'preferred_username'
    scope = ['openid'] + ([scope_required] if scope_required else [])
    auto_login = True
    refresh_pre_spawn = True
    # To force jupyterhub check access token when everytime api called, default refresh age should be -1
    auth_refresh_age = get_primehub_config('authRefreshAge', -1)
    client = httpclient.AsyncHTTPClient(max_clients=64)
    login_handler = OIDCLoginHandler
    logout_handler = OIDCLogoutHandler

    # the flag introduced at 0.8, we need it to make jupyterhub to save the auth_state, otherwise it would become None
    enable_auth_state = True

    @default("authorize_url")
    def _authorize_url_default(self):
        return '%s/realms/%s/protocol/openid-connect/auth' % (keycloak_app_url, realm)

    @default("token_url")
    def _token_url_default(self):
        return '%s/realms/%s/protocol/openid-connect/token' % (keycloak_url, realm)

    async def verify_access_token(self, user):
        auth_state = user.get_auth_state()
        while asyncio.iscoroutine(auth_state) or asyncio.isfuture(auth_state):
            auth_state = await auth_state

        access_token = auth_state['access_token']
        token_type = 'Bearer'

        # Determine who the logged in user is
        headers = {
            "Accept": "application/json",
            "User-Agent": "JupyterHub",
            "Authorization": "{} {}".format(token_type, access_token)
        }

        try:
            response = await self.client.fetch(self.userdata_url,
                                               method='GET',
                                               headers=headers)
            if response.code == 200:
                return True
            else:
                return False
        except Exception as e:
            return False

    async def refresh_user(self, user, handler=None):
        # prevent multiple graphql calls
        if isinstance(handler, (LoginHandler, OAuthCallbackHandler)):
            self.log.debug('skip refresh user in handler: %s', handler)
            return False

        self.log.debug('refresh user: %s', user)
        auth_state = user.get_auth_state()
        if asyncio.iscoroutine(auth_state):
            auth_state = await auth_state

        user_id = auth_state['oauth_user'].get('sub', None)
        if not user_id:
            self.log.debug('user id not found')
            return False

        is_valid_token = await self.verify_access_token(user)
        if is_valid_token == False:
            self.log.debug('Expire access token: %s', user.name)
            return False

        try:
            updated_ctx = await fetch_context(user_id)
            if asyncio.iscoroutine(updated_ctx):
                updated_ctx = await updated_ctx
        except:
            return True
        unchanged = True
        unchanged = unchanged and updated_ctx['user'] == auth_state['launch_context']
        unchanged = unchanged and updated_ctx['system'] == auth_state['system']

        if unchanged:
            return True
        else:
            self.log.debug(
                'user %s is outdated, update state',
                auth_state['oauth_user'].get(
                    'preferred_username',
                    None))
            auth_state['launch_context'] = updated_ctx['user']
            auth_state['system'] = updated_ctx['system']
            return dict(auth_state=auth_state)

    async def is_admin(self, handler, authentication):
        return authentication['auth_state']['launch_context'].get(
            'isAdmin', False)

    async def authenticate(self, handler, data=None):
        user = await super().authenticate(handler, data)
        if not user:
            return
        self.log.debug("auth: %s", user['auth_state'])
        if scope_required and not scope_required in user['auth_state']['oauth_user']['roles']:
            return
        user_id = user['auth_state']['oauth_user'].get('sub', None)
        if user_id is None:
            self.log.debug('user id not found')
            return

        try:
            ctx = await fetch_context(user_id)
            user['auth_state']['launch_context'] = ctx.get('user', {})
            user['auth_state']['system'] = ctx.get('system', {})
        except Exception as e:
            # error: 'API_UNAVAILABLE' if kube-apiserver is down.
            user['auth_state']['error'] = str(e)
            user['auth_state']['launch_context'] = {}
            user['auth_state']['system'] = {}

        return user

    def get_handlers(self, app):
        return super().get_handlers(app) + [(r'/logout', self.logout_handler)]

    def attach_project_pvc(self, spawner, project, group, size):
        spawner.volumes.append({'name': 'project-' + project,
                                'persistentVolumeClaim': {'claimName': 'project-' + project}})
        spawner.volume_mounts.append(
            {'mountPath': '/project/' + project, 'name': 'project-' + project})

    async def post_spawn_stop(self, user, spawner):
        started_at = None
        duration = None
        if spawner.started_at is not None:
            started_at = datetime.utcfromtimestamp(int(spawner.started_at)).isoformat()
            duration = int(time.time() - spawner.started_at)
        gpu_enabled = spawner.extra_resource_limits.get('nvidia.com/gpu', 0) > 0
        status = 'Success'
        if (len([1 for e in spawner.events if 'Failed' in e['reason']]) > 0):
            status = 'Failed'

        traits = {
            'notebookStartedAt': started_at,
            'notebookGpu': gpu_enabled,
            'notebookStatus': status,
            'notebookDuration': duration
        }
        send_telemetry(traits)
        self.log.debug('send telemetry {}'.format(traits))

        self.log.debug("post spawn stop for %s", user)
        user.spawners.pop('')

    async def get_custom_resources(self, namespace, plural):
        api_instance = shared_client('CustomObjectsApi')
        group = 'primehub.io'
        version = 'v1alpha1'

        api_response = await api_instance.list_namespaced_custom_object(
            group, version, namespace, plural)
        return api_response['items']

    # logic of determing user volume capacity
    def user_volume_capacity(self, auth_state):
        default_capacity = auth_state.get('system', {}).get(
            'defaultUserVolumeCapacity', None)
        user_capacity = auth_state['launch_context'].get(
            'volumeCapacity', None)

        if user_capacity:
            return user_capacity

        return default_capacity

    def get_mlflow_environment_variables(self, launch_group_name, auth_state):
        for group in auth_state['launch_context']['groups']:
            if group['name'] == launch_group_name:
                mlflow = group.get('mlflow', None)

                # Do nothing without mlflow
                if not mlflow:
                    return {}

                # example for mlflow configurations
                """
                {
                  "trackingUri": "http://foobar.com",
                  "uiUrl": "http://uiurl",
                  "trackingEnvs": [
                    {
                      "name": "MLFLOW_TRACKING_USERNAME",
                      "value": "foo"
                    },
                    {
                      "name": "MLFLOW_TRACKING_PASSWORD",
                      "value": "bar"
                    }
                  ],
                  "artifactEnvs": [
                    {
                      "name": "AWS_ACCESS_KEY_ID",
                      "value": "foo"
                    },
                    {
                      "name": "AWS_SECRET_ACCESS_KEY",
                      "value": "bar"
                    }
                  ]
                }
                """

                mlflow_envs = dict()
                if mlflow.get('trackingUri', None):
                    mlflow_envs['MLFLOW_TRACKING_URI'] = mlflow['trackingUri']
                if mlflow.get('uiUrl', None):
                    mlflow_envs['MLFLOW_UI_URL'] = mlflow['uiUrl']
                for env_var in mlflow.get('trackingEnvs', []) + mlflow.get('artifactEnvs', []):
                    mlflow_envs[env_var['name']] = env_var['value']
                return mlflow_envs
        return {}

    def get_datasets_in_launch_group(self, launch_group_name, auth_state):
        for group in auth_state['launch_context']['groups']:
            if group['name'] == launch_group_name:
                result = {}
                if group.get('datasets', None):
                    for dataset_policy in group['datasets']:
                        result[dataset_policy['name']] = dataset_policy
                return result
        return {}

    def get_global_datasets(self, groups):
        global_datasets = {}

        def _append_dataset(dataset):
            global_datasets[dataset['name']] = dataset

        for group in groups:
            if group and group.get('datasets', None):
                list(map(_append_dataset, filter(
                    lambda d: d['global'] == True, group['datasets'])))
        return global_datasets

    def mount_dataset(self, spawner, global_datasets, datasets_in_launch_group, name, dataset):
        annotations = dataset['metadata'].get('annotations', {})
        launch_group_only = annotations.get(
            'dataset.primehub.io/launchGroupOnly', 'false') == 'true'
        is_global = name in global_datasets.keys()

        self.log.debug(
            'Datasets in launch group [%s]: %s' % (spawner.user_options['group']['name'], datasets_in_launch_group))

        # Check if dataset should mount.
        if not is_global and (launch_group_only and name not in datasets_in_launch_group):
            return False

        spec = dataset['spec']
        type = spec.get('type')

        if type == 'env':
            variables = spec.get('variables', {})
            ds_env = {}
            pattern = re.compile(r'[-._a-zA-Z][-._a-zA-Z0-9]*')

            for key, value in variables.items():
                # XXX: work around for
                # https://gitlab.com/infuseai/canner-admin-ui/issues/55
                if key == '__typename':
                    continue
                env_key = ('%s_%s' % (name, key)).upper()
                match = pattern.fullmatch(env_key)
                if match is None:
                    self.log.debug(
                        "[%s] is a invalid env key. Discarded" %
                        env_key)
                    continue
                # For backward compatibility in env
                ds_env[env_key] = value
                # Actually, hyphen is not supported in bash
                ds_env[env_key.replace('-', '_')] = value

            spawner.environment.update(ds_env)
        else:
            home_symlink = annotations.get(
                'dataset.primehub.io/homeSymlink', 'false') == 'true'
            mount_root = annotations.get(
                'dataset.primehub.io/mountRoot', '/datasets/')
            mount_path = os.path.join(mount_root, name)
            dataset_prefix = 'dataset-%s'
            logic_name = dataset_prefix % name

            writable = datasets_in_launch_group.get(name, {}).get('writable', False)
            if is_global:
                writable = writable or global_datasets.get(name, {}).get('writable', False)

            if type == 'git':
                gitsync_host_root = annotations.get(
                    'dataset.primehub.io/gitSyncHostRoot', '/home/dataset/')
                gitsync_root = annotations.get(
                    'dataset.primehub.io/gitSyncRoot', '/gitsync/')

                gitsync_mount_path = os.path.join(gitsync_root, name)
                spawner.volume_mounts.append(
                    {'mountPath': gitsync_mount_path, 'name': logic_name, 'readOnly': True})
                spawner.volumes.append(
                    {'name': logic_name, 'hostPath': {'path': os.path.join(gitsync_host_root, name)}})

                self.symlinks.append('mkdir -p %s' % mount_root)
                self.symlinks.append(
                    'ln -sf %s %s' %
                    (os.path.join(gitsync_mount_path, name), mount_path))
            elif type == 'pv':
                volume_name = spec.get('volumeName')

                spawner.volume_mounts.append(
                    {'mountPath': mount_path, 'name': logic_name, 'readOnly': not writable})
                if writable:
                    self.chown_extra.append(mount_path)

                # Deprecated
                if re.match('^hostpath:', volume_name):
                    path = re.sub('^hostpath:', '', volume_name)
                    spawner.volumes.append(
                        {'name': logic_name, 'hostPath': {'path': path}})
                else:
                    spawner.volumes.append({
                        'name': logic_name,
                        'persistentVolumeClaim': {'claimName': dataset_prefix % volume_name, 'readOnly': not writable}
                    })
            elif type == 'hostPath':
                path = spec.get('hostPath', {}).get('path', None)
                if path:
                    if writable:
                        self.chown_extra.append(mount_path)

                    spawner.volume_mounts.append(
                        {'mountPath': mount_path, 'name': logic_name, 'readOnly': not writable})
                    spawner.volumes.append(
                        {'name': logic_name, 'hostPath': {'path': path}})
            elif type == 'nfs':
                path = spec.get('nfs', {}).get('path', None)
                server = spec.get('nfs', {}).get('server', None)
                if path and server:
                    if writable:
                        self.chown_extra.append(mount_path)

                    spawner.volume_mounts.append(
                        {'mountPath': mount_path, 'name': logic_name, 'readOnly': not writable})
                    spawner.volumes.append(
                        {'name': logic_name, 'nfs': {'path': path, 'server': server}})

            if home_symlink:
                self.symlinks.append('ln -sf %s /home/jovyan/' % mount_path)

        return True

    async def pre_spawn_start(self, user, spawner):
        """Pass upstream_token to spawner via environment variable"""
        auth_state = await user.get_auth_state()

        if not auth_state:
            raise Exception('auth state must be enabled')

        self.log.debug("user spawn options: %s", spawner.user_options)

        storage_capacity = self.user_volume_capacity(auth_state)
        if storage_capacity:
            self.log.info(
                "setting user storage capacity to: %dG" %
                storage_capacity)
            spawner.storage_capacity = str(storage_capacity) + "Gi"

        spawner.environment.update(
            {
                'TZ': auth_state['oauth_user'].get('timezone', 'UTC'),
                'GROUP_ID': spawner.user_options.get('group', {}).get('id', ''),
                'GROUP_NAME': spawner.user_options.get('group', {}).get('name', ''),
                'INSTANCE_TYPE': spawner.user_options.get('instance_type', ''),
                'IMAGE_NAME': spawner.user_options.get('image', ''),
                'GRANT_SUDO': 'yes' if grantSudo == True else 'no'
            }
        )

        if spawner.extra_resource_limits.get('nvidia.com/gpu', 0) == 0:
            spawner.environment.update({'NVIDIA_VISIBLE_DEVICES': 'none'})
        if spawner.ssh_config['enabled']:
            spawner.environment.update({'PRIMEHUB_START_SSH': 'true'})
            spawner.extra_labels['ssh-bastion-server/notebook'] = 'true'

        if start_notebook_config:
            spawner.volumes.append(
                {'name': 'start-notebook-d', 'config_map': {'name': start_notebook_config}})
            spawner.volume_mounts.append(
                {'mountPath': '/usr/local/bin/start-notebook.d', 'name': 'start-notebook-d'})

        self.chown_extra = []
        primehub_datasets = {}

        try:
            self.log.info("oauth_user %s" % auth_state['oauth_user'])
            namespace = os.environ.get('POD_NAMESPACE', 'hub')
            primehub_datasets = {
                item['metadata']['name']: item for item in (await self.get_custom_resources(
                    namespace, 'datasets'))}
        except BaseException as e:
            print(
                "Exception when calling CustomObjectsApi->get_namespaced_custom_object: %s\n" %
                e)
            traceback.print_tb()

        self.symlinks = ["ln -sf /datasets /home/jovyan/"]
        global_datasets = self.get_global_datasets(auth_state['launch_context']['groups'])
        datasets_in_launch_group = self.get_datasets_in_launch_group(
            launch_group_name=spawner.user_options['group']['name'], auth_state=auth_state)
        # Mount datasets.
        # TODO: Add unittests for Mount datasets.
        roles = auth_state['oauth_user']['roles']

        for name, dataset in primehub_datasets.items():
            if ('%sds:%s' % (role_prefix, name) not in roles) and ('%sds:rw:%s' % (role_prefix, name) not in roles):
                self.log.debug('[skip-info] :: roles: [%s], role_prefix: [%s], name: [%s]' % (roles, role_prefix, name))
                self.log.debug(
                    '[skip-info] :: (%s, %s)' % ('%sds:%s' % (role_prefix, name), '%sds:rw:%s' % (role_prefix, name)))
                continue
            mounted = self.mount_dataset(spawner, global_datasets, datasets_in_launch_group, name, dataset)
            self.log.debug(
                "  %s dataset %s (type %s)", ('mounting' if mounted else 'skipped'), name, type)

        launch_group = spawner.user_options['group']['name']
        groups = auth_state['launch_context']['groups']

        mlflow_envs = self.get_mlflow_environment_variables(launch_group, auth_state)
        if mlflow_envs:
            spawner.environment.update(mlflow_envs)

        for group in groups:
            if not group.get('enabledSharedVolume', False):
                continue

            shared_volume_capacity = group.get('sharedVolumeCapacity', None)
            home_symlink = group.get('homeSymlink', True)
            launch_group_only = group.get('launchGroupOnly', True)

            if not shared_volume_capacity:
                raise Exception(
                    'sharedVolumeCapacity cannot be None when enabledSharedVolume is True.')

            if not launch_group_only or (launch_group_only and launch_group == group['name']):
                name = re.sub('_', '-', group['name']).lower()
                # Append Gi to end of shared volume capacity string
                size = '%sGi' % str(shared_volume_capacity)
                self.attach_project_pvc(spawner, name, name, size)
                self.chown_extra.append('/project/' + name)
                if home_symlink:
                    self.symlinks.append('ln -sf /project/%s /home/jovyan/' % name)

        if phfs_enabled:
            spawner.volumes.append({'name': 'phfs',
                                    'persistentVolumeClaim': {'claimName': phfs_pvc}})
            spawner.volume_mounts.append(
                {'mountPath': '/phfs', 'name': 'phfs', 'subPath': 'groups/' + re.sub('_', '-', launch_group).lower()})
            self.chown_extra.append('/phfs')
            self.symlinks.append('ln -sf /phfs /home/jovyan/')

        # We have to chown the home directory since we disabled the kubelet fs_group.
        # Newly created home volume needs this to work.
        self.chown_extra.append('/home/jovyan')

        if not spawner.init_containers:
            spawner.init_containers = []

        self.setup_admission_not_found_init_container(spawner)
        self.setup_primehub_examples_init_container(spawner)

        spawner.environment.update({
            'CHOWN_EXTRA': ','.join(self.chown_extra)
        })

        # use preStop hook to ensure jupyter's metadata owner back to the jovyan user
        spawner.lifecycle_hooks = {
            'postStart': {'exec': {'command': ['bash', '-c', ';'.join(self.symlinks)]}},
            'preStop': {'exec': {
                'command': ['bash', '-c', ';'.join(["chown -R 1000:100 /home/jovyan/.local/share/jupyter || true"])]}}
        }

        # add labels for resource validation
        spawner.extra_labels['primehub.io/user'] = escape_to_primehub_label(spawner.user.name)
        spawner.extra_labels['primehub.io/group'] = escape_to_primehub_label(
            spawner.user_options.get('group', {}).get('name', ''))

        self.attach_usage_annoations(spawner)
        self.mount_primehub_scripts(spawner)

        origin_args = spawner.get_args()

        def empty_list():
            return []

        spawner.get_args = empty_list
        spawner.cmd = ['/opt/primehub-start-notebook/primehub-entrypoint.sh'] + origin_args

        if spawner.enable_safe_mode:
            spawner.environment['PRIMEHUB_SAFE_MODE_ENABLED'] = "true"
            self.log.warning('enable safe mode')
            # rescue mode: change home-volume mountPath
            for m in spawner.volume_mounts:
                if m['mountPath'] == '/home/jovyan':
                    m['mountPath'] = '/home/jovyan/user'
            self.support_repo2docker(spawner)

        spawner.set_launch_group(launch_group)
        spawner.started_at = time.time()
        self.log.warning(spawner.init_containers)
        spawner.environment['PRE_SPAWN_START_FINISHED'] = 'finished'

    def setup_admission_not_found_init_container(self, spawner):
        # In order to check it passed the admission, set a bad initcontainer and admission will remove this initcontainer.
        spawner.init_containers.append({
            "name": "admission-is-not-found",
            "image": "admission-is-not-found",
            "imagePullPolicy": "Never",
            "command": ["false"],
        })

    def setup_primehub_examples_init_container(self, spawner):
        cfg = get_primehub_config('primehub-examples', {})
        repository = "infuseai/primehub-examples"
        tag = 'latest'
        policy = 'IfNotPresent'

        if cfg:
            if 'repository' in cfg:
                repository = cfg['repository']

            if 'tag' in cfg:
                tag = cfg['tag']

            if 'pullPolicy' in cfg:
                policy = cfg['pullPolicy']

            if tag == 'latest':
                policy = 'Always'

        spawner.init_containers.append({
            "command": [
                "sh",
                "-c",
                "cp -R /data/. /primehub-examples"
            ],
            "image": "{}:{}".format(repository, tag),
            "imagePullPolicy": policy,
            "name": "primehub-examples",
            "resources": {},
            "securityContext": {
                "runAsGroup": 100,
                "runAsUser": 1000
            },
            "volumeMounts": [
                {
                    "mountPath": "/primehub-examples",
                    "name": "primehub-examples"
                }
            ]
        })
        self.symlinks.append('ln -sf /primehub-examples /home/jovyan/')

    def attach_usage_annoations(self, spawner):
        usage_annotation = dict(component='notebook',
                                component_name=spawner.pod_name,
                                group=spawner.user_options.get('group', {}).get('name', ''),
                                user=spawner.user.name,
                                instance_type=spawner.user_options.get('instance_type', ''))
        value = json.dumps(usage_annotation)
        # convert json format `{ }` to `{{ }}` to escape curly-brace characters in the python template
        spawner.extra_annotations['primehub.io/usage'] = '{%s}' % value

    def support_repo2docker(self, spawner):
        # mount extra scripts for repo2docker
        spawner.environment['R2D_ENTRYPOINT'] = '/opt/primehub-start-notebook/primehub-start-notebook.sh'

    def mount_primehub_scripts(self, spawner):
        spawner.volumes.append({
            'configMap': {
                'defaultMode': 0o0777,
                'name': 'primehub-start-notebook'
            },
            'name': 'primehub-start-notebook'
        })
        spawner.volume_mounts.append({
            'mountPath': '/opt/primehub-start-notebook',
            'name': 'primehub-start-notebook'
        })


class PrimeHubPodReflector(NamespacedResourceReflector):
    kind = 'pods'
    list_method_name = 'list_namespaced_pod'
    labels = {}

    @property
    def pods(self):
        return self.resources


class PrimeHubSpawner(KubeSpawner):
    enable_safe_mode = False
    ssh_config = dict(enabled=False)
    _launch_group = None
    _active_group = None
    _launch_path = None
    _default_image = None
    _default_instance_type = None
    _autolaunch = None
    started_at = None
    created_time = None
    launch_image = ""
    instance_type = ""

    @property
    def primehub_pod_reflector(self):
        """
        A convinience alias to the class variable reflectors['primehub_pods'].
        """
        return self.__class__.reflectors['primehub_pods']

    def __init__(self, *args, **kwargs):
        _mock = kwargs.get('_mock', False)
        super().__init__(*args, **kwargs)

        if not _mock:
            self._start_reflector("primehub_pods", PrimeHubPodReflector, replace=True)

    def instance_type_to_override(self, instance_type):
        spec = instance_type['spec']
        gpu = spec.get('limits.nvidia.com/gpu', None)
        extra_resource_limits = {'nvidia.com/gpu': gpu} if gpu else {}

        # there are default value set on
        # .Values.singleuser.cpu.guarantee
        # .Values.singleuser.cpu.limit
        # .Values.singleuser.memory.guarantee
        # .Values.singleuser.memory.limit
        # .Values.singleuser.extraResource.guarantees
        # .Values.singleuser.extraResource.limit
        result = {
            'cpu_guarantee': float(spec.get('requests.cpu', 0)),
            'cpu_limit': float(spec.get('limits.cpu', 1)),
            'mem_limit': spec.get('limits.memory', '1G'),
            'mem_guarantee': spec.get('requests.memory', '0G'),
            'extra_resource_limits': extra_resource_limits
        }

        # pod spec override
        override_fields = [
            {'spec_key': 'nodeSelector', 'key': 'node_selector', 'default': {}},
            {'spec_key': 'tolerations', 'key': 'tolerations', 'default': []},
        ]

        for field in override_fields:
            if spec.get(field['spec_key'], None):
                result[field['key']] = spec.get(
                    field['spec_key'], field['default'])

        return result

    def image_to_override(self, image, gpu_request):
        is_gpu = gpu_request > 0
        spec = image['spec']
        url = spec.get('url', None)
        if is_gpu:
            url = spec.get('urlForGpu', spec.get('url', None))

        result = {
            'image': url
        }

        pull_secret = spec.get('pullSecret', None)
        if pull_secret:
            result['image_pull_secrets'] = pull_secret

        return result

    def render_html(self, template_name, **local_vars):
        template = template_loader.get_template(template_name)
        return template.render(**local_vars)

    def _options_form_default(self):
        return self._render_options_form_dynamically

    def merge_group_properties(self, key, groups):
        seen = set()
        return [x for g in groups for x in g.get(key, []) if x['name']
                not in seen and not seen.add(x['name'])]

    @property
    def launch_group(self):
        return self._launch_group

    def set_launch_group(self, launch_group):
        self._launch_group = launch_group

    @property
    def active_group(self):
        return self._active_group

    def set_active_group(self, active_group):
        self._active_group = active_group

    @property
    def launch_path(self):
        return self._launch_path

    def set_launch_path(self, launch_path):
        self._launch_path = launch_path

    @property
    def default_image(self):
        return self._default_image

    def set_default_image(self, default_image):
        self._default_image = default_image

    @property
    def default_instance_type(self):
        return self._default_instance_type

    def set_default_instance_type(self, default_instance_type):
        self._default_instance_type = default_instance_type

    @property
    def autolaunch(self):
        return self._autolaunch

    def set_autolaunch(self, autolaunch):
        self._autolaunch = autolaunch

    def get_state(self):
        """get the current state"""
        state = super().get_state()
        if self.launch_group:
            state['launch_group'] = self.launch_group
        self.log.info("get_state: %s" % self._launch_group)
        if self.launch_path:
            state['launch_path'] = self.launch_path
        self.log.info("launch_path: %s" % self.launch_path)
        if self.default_image:
            state['default_image'] = self.default_image
        self.log.info("default_image: %s" % self.default_image)
        if self.default_instance_type:
            state['default_instance_type'] = self.default_instance_type
        self.log.info("default_instance_type: %s" % self.default_instance_type)
        if self.autolaunch:
            state['autolaunch'] = self.autolaunch
        self.log.info("default_instance_type: %s" % self.autolaunch)
        return state

    def load_state(self, state):
        """load state from the database"""
        super().load_state(state)
        if 'launch_group' in state:
            self._launch_group = state['launch_group']
        self.log.info("load_state: %s" % self._launch_group)
        if self.launch_path:
            state['launch_path'] = self.launch_path
        if self.default_image:
            state['default_image'] = self.default_image
        if self.default_instance_type:
            state['default_instance_type'] = self.default_instance_type
        if self.autolaunch:
            state['autolaunch'] = self.autolaunch

    def clear_state(self):
        """clear any state (called after shutdown)"""
        super().clear_state()
        self._launch_group = None
        self.log.info("clear_state: %s" % self._launch_group)

    async def _render_options_form_dynamically(self, current_spawner):
        self.log.debug("render_options for %s", self._log_name)
        auth_state = await self.user.get_auth_state()
        if not auth_state:
            raise Exception('no auth state')
        context = auth_state.get('launch_context', None)
        error = auth_state.get('error', None)

        if error == BACKEND_API_UNAVAILABLE:
            return self.render_html('spawn_block.html', block_msg='Backend API unavailable. Please contact admin.')

        if not context:
            return self.render_html('spawn_block.html', block_msg='Sorry, but you need to relogin to continue',
                                    href='/hub/logout')

        try:
            groups = self._groups_from_ctx(context)
            self._groups = groups
        except Exception:
            self.log.error('Failed to fetch groups', exc_info=True)
            return self.render_html('spawn_block.html',
                                    block_msg='No group is configured for you to launch a server. Please contact admin.')

        self.user.spawner.ssh_config['host'] = get_primehub_config('sshServer.customHostname',
                                                                   get_primehub_config('host', ''))
        self.user.spawner.ssh_config['hostname'] = '{}.{}'.format(self.user.spawner.pod_name,
                                                                  os.environ.get('POD_NAMESPACE', 'hub'))
        self.user.spawner.ssh_config['port'] = get_primehub_config('sshServer.servicePort', '2222')

        return self.render_html('groups.html',
                                groups=groups,
                                default_image=self.user.spawner.default_image,
                                default_instance_type=self.user.spawner.default_instance_type,
                                autolaunch=self.user.spawner.autolaunch,
                                active_group=self.active_group,
                                enable_ssh_server=enable_feature_ssh_server,
                                ssh_config=self.user.spawner.ssh_config)

    def get_container_resource_usage(self, group):
        try:
            return self._get_container_resource_usage(group)
        except Exception:
            self.log.error('Failed to calculate resource usages', exc_info=True)

    def _get_container_resource_usage(self, group):
        existing = []
        for item in self.primehub_pod_reflector.pods.values():
            pod = item
            if not isinstance(item, dict):
                pod = item.to_dict()

            labels = pod.get('metadata', {}).get('labels', None)
            phase = pod.get('status', {}).get('phase', None)
            if labels and labels.get("primehub.io/group", "") == escape_to_primehub_label(group["name"]) \
                and (phase == "Pending" or phase == "Running"):
                existing += pod.get('spec', {}).get('containers', {})

        def limit_of(container, name):
            return container.get('resources', {}).get('limits', {}).get(name, 0)

        def has_limit(container):
            return container.get('resources', {}).get('limits', {})

        cpu, gpu, mem = (0, 0, 0)
        # some functions are under primehub_utils.py
        cpu = sum([float(convert_cpu_values_to_float(limit_of(container, 'cpu')))
                   for container in existing if has_limit(container)])
        gpu = sum([int(limit_of(container, 'nvidia.com/gpu'))
                   for container in existing if has_limit(container)])
        mem = sum([int(convert_mem_resource_to_bytes(limit_of(container, 'memory')))
                   for container in existing if has_limit(container)])
        mem = round(float(mem / GiB()), 1)  # convert to GB

        return {'cpu': cpu, 'gpu': gpu, 'memory': mem}

    def _groups_from_ctx(self, context):
        role_groups = [group for group in context['groups']
                       if group['name'] == 'everyone']
        groups = [
            {
                **(group),
                **({
                    'datasets': self.merge_group_properties('datasets', [group] + role_groups),
                    'images': self.merge_group_properties('images', [group] + role_groups),
                    'instanceTypes': self.merge_group_properties('instanceTypes', [group] + role_groups)
                }),
                'usage': self.get_container_resource_usage(group)
            } for group in context['groups'] if group['name'] != 'everyone']

        if not len(groups):
            raise Exception(
                'Not enough resource limit in your groups, please contact admin.')

        def map_group(group):
            if group.get('displayName', None) is None or group.get('displayName', None) is '': group[
                'displayName'] = group.get('name', '')
            return group

        groups = list(map(map_group, groups))
        return groups

    def get_default_image(self):
        return self.config.get('KubeSpawner', {}).get('image', '')

    async def update_predefined_vars(self, flatten_env_dict):
        auth_state = await self.user.get_auth_state()
        user_id = auth_state['oauth_user'].get('sub', None)
        await update_user_predefined_envs(user_id, flatten_env_dict)

    async def options_from_form(self, formdata):
        if enable_feature_ssh_server:
            self.ssh_config['enabled'] = formdata.get('ssh_server', ['off']) == ['on']
        self.enable_safe_mode = formdata.get('safe_mode', ['off']) == ['on']

        self.log.debug("options_from_form for %s", self._log_name)
        if not hasattr(self, '_groups'):
            raise Exception('no groups info')
        options = {
            'instance_type': formdata['instance_type'][0],
            'image': formdata['image'][0],
        }
        [group] = [group for group in self._groups if group['name']
                   == formdata['group'][0]]
        [it] = [it for it in group['instanceTypes']
                if it['name'] == options['instance_type']]
        [img] = [img for img in group['images'] if img['name'] == options['image']]
        options['group'] = {k: group[k]
                            for k in ['id', 'name', 'quotaGpu', 'projectQuotaGpu']}

        self.log.debug("SPAWN: %s / %s", it, img)

        self.extra_labels['project'] = group['name']

        self.apply_kubespawner_override(self.instance_type_to_override(it))

        gpu_request = int(it['spec'].get('limits.nvidia.com/gpu', 0))
        self.apply_kubespawner_override(self.image_to_override(img, gpu_request))

        try:
            self.instance_type = formdata.get('instance_type_display_name')[0]
            self.launch_image = formdata.get('image_display_name')[0]

            # it will be converted by a local time when the client rendering
            self.created_time = int(time.time() * 1000)
        except:
            self.instance_type = '<unknown>'
            self.launch_image = '<unknown>'
            pass

        # user-predefined envs
        env = await self._get_env_options(formdata)
        if env:
            options["env"] = env

        return options

    async def _get_env_options(self, formdata):
        env_key_re = r'^env_var_(\d+)_key$'
        env_value_re = r'^env_var_(\d+)_value$'
        env_dict = {}
        for k, v in formdata.items():
            key_match = re.match(env_key_re, k)
            if key_match:
                if key_match.group(1) not in env_dict:
                    env_dict[key_match.group(1)] = {}
                env_dict.get(key_match.group(1), {})["key"] = v[0]
            value_match = re.match(env_value_re, k)
            if value_match:
                if value_match.group(1) not in env_dict:
                    env_dict[value_match.group(1)] = {}
                env_dict.get(value_match.group(1), {})["value"] = v[0]
        if env_dict:
            flatten_env_dict = {}
            for _, val in env_dict.items():
                k = val["key"].strip()
                if not re.match(r'[-._a-zA-Z][-._a-zA-Z0-9]*', k):
                    raise web.HTTPError(
                        400, "Valid environment variable name must consist of alphabetic characters, digits, '_', '-', or '.', and must not start with a digit"
                    )
                v = val["value"].strip()
                if k and v:
                    flatten_env_dict[k] = v
            await self.update_predefined_vars(flatten_env_dict)
            return flatten_env_dict

    def apply_kubespawner_override(self, kubespawner_override):
        for k, v in kubespawner_override.items():
            if callable(v):
                v = v(self)
                self.log.debug(
                    ".. overriding KubeSpawner value %s=%s (callable result)", k, v)
            else:
                self.log.debug(".. overriding KubeSpawner value %s=%s", k, v)
            setattr(self, k, v)

    def fs_gid(self, spawner):
        self.log.warning("overriding fs_group_id to %s", fs_group_id)
        return fs_group_id

    def get_env(self):
        env = super().get_env()
        if self.user_options.get('env'):
            env.update(self.user_options['env'])
        return env


class StopSpawningHandler(BaseHandler):
    @web.authenticated
    async def get(self, for_user=None):
        user = current_user = self.current_user
        self.log.debug('current user: %s', user.name)
        self.log.debug('for user: %s', for_user)
        if for_user is not None and for_user != user.name:
            if not user.admin:
                raise web.HTTPError(
                    403, "Only admins can spawn on behalf of other users"
                )

            user = self.find_user(for_user)
            if user is None:
                raise web.HTTPError(404, "No such user: %s" % for_user)
        spawner = user.spawner
        if not spawner.active:
            self.log.debug('Spawner is not active')
            await self.finish()
            return
        auth_state = await user.get_auth_state()
        error = auth_state.get('error', None)
        if error == BACKEND_API_UNAVAILABLE:
            await self.finish(dict(error=error))

        def _remove_spawner():
            self.log.info("Deleting spawner %s", spawner._log_name)
            self.db.delete(spawner.orm_spawner)
            user.spawners.pop(spawner.name, None)
            self.db.commit()

        await user.stop()
        if spawner.pending is not None:
            _remove_spawner()

        self.redirect(url_path_join(self.hub.base_url, 'spawn', user.escaped_name))


class ResourceUsageHandler(BaseHandler):
    @web.authenticated
    async def get(self, for_user=None):
        user = current_user = self.current_user
        self.log.debug('current user: %s', user.name)
        self.log.debug('for user: %s', for_user)
        if for_user is not None and for_user != user.name:
            if not user.admin:
                raise web.HTTPError(
                    403, "Only admins can spawn on behalf of other users"
                )

            user = self.find_user(for_user)
            if user is None:
                raise web.HTTPError(404, "No such user: %s" % for_user)
        spawner = user.spawner
        auth_state = await user.get_auth_state()
        error = auth_state.get('error', None)
        if error == BACKEND_API_UNAVAILABLE:
            self.finish(dict(error=error))
        groups = spawner._groups_from_ctx(auth_state['launch_context'])
        # Tornado will response json when give chuck as a dictionary.
        try:
            predefinedEnvs = json.loads(auth_state['launch_context']['predefinedEnvs'])
            if not isinstance(predefinedEnvs, dict):
                predefinedEnvs = {}
        except:
            predefinedEnvs = {}
        self.finish(dict(groups=groups, predefinedEnvs=predefinedEnvs))


class PrimeHubHomeHandler(BaseHandler):
    """Render the user's home page."""

    @web.authenticated
    async def get(self):
        user = self.current_user
        if user.running:
            # trigger poll_and_notify event in case of a server that died
            await user.spawner.poll_and_notify()

        # send the user to /spawn if they have no active servers,
        # to establish that this is an explicit spawn request rather
        # than an implicit one, which can be caused by any link to `/user/:name(/:server_name)`
        if user.active:
            url = url_path_join(self.base_url, 'user', user.escaped_name)
        else:
            url = url_path_join(self.hub.base_url, 'spawn', user.escaped_name)

        group = self.get_query_argument("group", default=None)
        launch_path = self.get_query_argument("path", default=None)
        default_image = self.get_query_argument("image", default=None)
        default_instance_type = self.get_query_argument("instancetype", default=None)
        autolaunch = self.get_query_argument("autolaunch", default=None)
        if user.spawner:
            user.spawner.set_active_group(group)
            user.spawner.set_launch_path(launch_path)
            user.spawner.set_default_image(default_image)
            user.spawner.set_default_instance_type(default_instance_type)
            user.spawner.set_autolaunch(autolaunch)
            # If it is spawning, show the spawn pending page.
            if user.spawner.pending == 'spawn':
                self.redirect(url)
                return
            if not user.active and launch_path:
                self.redirect(url)
                return

        html = self.render_template(
            'home.html',
            user=user,
            url=url,
            allow_named_servers=self.allow_named_servers,
            named_server_limit_per_user=self.named_server_limit_per_user,
            url_path_join=url_path_join,
            group=group,
            # can't use user.spawners because the stop method of User pops named servers from user.spawners when they're stopped
            spawners=user.orm_user._orm_spawners,
            default_server=user.spawner,
            sync=True
        )
        self.finish(html)


if locals().get('c') and not os.environ.get('TEST_FLAG'):

    c = locals().get('c')

    if c.JupyterHub.log_level != 'DEBUG':
        c.JupyterHub.log_level = 'WARN'
    c.JupyterHub.log_level = 'INFO'

    c.JupyterHub.log_format = "%(color)s[%(levelname)s %(asctime)s.%(msecs).03d %(name)s %(module)s:%(lineno)d]%(end_color)s %(message)s"
    c.JupyterHub.authenticator_class = OIDCAuthenticator
    c.JupyterHub.spawner_class = PrimeHubSpawner
    c.JupyterHub.tornado_settings = {
        'slow_spawn_timeout': 3,
        'slow_stop_timeout': 30
    }

    c.JupyterHub.extra_handlers = [
        (r"/api/primehub/groups", ResourceUsageHandler),
        (r"/api/primehub/groups/([^/]+)", ResourceUsageHandler),
        (r"/api/primehub/users/([^/]+)/stop-spawning", StopSpawningHandler),
        (r"/primehub/home", PrimeHubHomeHandler),
    ]

    c.JupyterHub.template_paths = [jupyterhub_template_path]
    c.JupyterHub.statsd_host = 'localhost'
    c.JupyterHub.statsd_port = 9125
    c.JupyterHub.statsd_prefix = 'jupyterhub'
    c.JupyterHub.authenticate_prometheus = False
    c.JupyterHub.template_vars = {'primehub_version': primehub_version}
    c.JupyterHub.logo_file = '/usr/local/share/jupyterhub/static/images/PrimeHub.png'
    c.PrimeHubSpawner.start_timeout = get_primehub_config('spawnerStartTimeout', 300)
    c.PrimeHubSpawner.http_timeout = get_primehub_config('spawnerHttpTimeout', 30)
    c.NamespacedResourceReflector.timeout_seconds = 45

    if not base_url:
        c.JupyterHub.base_url = base_url

    c.PrimeHubSpawner.node_affinity_required.extend(get_config('singleuser.extraNodeAffinity.required', []))
    c.PrimeHubSpawner.node_affinity_preferred.extend(get_config('singleuser.extraNodeAffinity.preferred', []))
    c.PrimeHubSpawner.pod_affinity_required.extend(get_config('singleuser.extraPodAffinity.required', []))
    c.PrimeHubSpawner.pod_affinity_preferred.extend(get_config('singleuser.extraPodAffinity.preferred', []))
    c.PrimeHubSpawner.pod_anti_affinity_required.extend(get_config('singleuser.extraPodAntiAffinity.required', []))
    c.PrimeHubSpawner.pod_anti_affinity_preferred.extend(get_config('singleuser.extraPodAntiAffinity.preferred', []))

    c.PrimeHubSpawner.extra_pod_config.update(get_config('singleuser.extraPodConfig', {}))

    # XXX: to be removed once we're sure we move all the custom config back into singleuser section
    c.PrimeHubSpawner.node_affinity_required.extend(
        get_primehub_config('node-affinity-required', []))
    c.PrimeHubSpawner.node_affinity_preferred.extend(
        get_primehub_config('node-affinity-preferred', []))
    c.PrimeHubSpawner.pod_affinity_required.extend(
        get_primehub_config('pod-affinity-required', []))
    c.PrimeHubSpawner.pod_affinity_preferred.extend(
        get_primehub_config('pod-affinity-preferred', []))
    c.PrimeHubSpawner.pod_anti_affinity_required.extend(
        get_primehub_config('pod-anti-affinity-required', []))
    c.PrimeHubSpawner.pod_anti_affinity_preferred.extend(
        get_primehub_config('pod-anti-affinity-preferred', []))

    # XXX: to be removed once kubespawner#251 is merged
    c.PrimeHubSpawner.extra_pod_config.update({'restartPolicy': 'OnFailure'})

    # override the security-context setting for GRANT_SUDO
    c.PrimeHubSpawner.allow_privilege_escalation = True
