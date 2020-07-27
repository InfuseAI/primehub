from kubespawner.clients import shared_client
from kubespawner import KubeSpawner
from pprint import pprint
import kubernetes.client
import re
import json
import urllib
import uuid
import os
import tornado.ioloop
import time
from z2jh import get_config
from tornado import gen, httpclient, web
from tornado.auth import OAuth2Mixin
from oauthenticator.generic import GenericLoginHandler, GenericOAuthenticator
from oauthenticator.oauth2 import OAuthCallbackHandler, OAuthLoginHandler
from jupyterhub.handlers import LoginHandler, LogoutHandler, BaseHandler
from jupyterhub.utils import url_path_join
from kubespawner.objects import make_pvc
from kubernetes.client.models import V1LabelSelector
from kubernetes.client.rest import ApiException
from traitlets import Any, Unicode, List, Integer, Union, Dict, Bool, Any, validate, default
from jinja2 import Environment, FileSystemLoader
from kubespawner.traitlets import Callable
from kubespawner.reflector import NamespacedResourceReflector

try:
    # it is for local development
    from primehub_utils import *
except Exception:
    pass

primehub_version = get_primehub_config('version')
keycloak_url = get_primehub_config('keycloak.url')
realm = get_primehub_config('keycloak.realm')

oidc_client_secret = get_primehub_config('clientSecret')
if not oidc_client_secret:
    oidc_client_secret = os.environ.get('KC_CLIENT_SECRET', '')
scope_required = get_primehub_config('scopeRequired')
role_prefix = get_primehub_config('keycloak.rolePrefix', "")
base_url = get_primehub_config('baseUrl', "/")
enable_feature_kernel_gateway = get_primehub_config('kernelGateway', "")
jupyterhub_template_path = '/etc/jupyterhub/templates'
start_notebook_config = get_primehub_config('startNotebookConfigMap')
template_loader = Environment(
    loader=FileSystemLoader(jupyterhub_template_path))

if role_prefix:
    role_prefix += ':'

graphql_endpoint = get_primehub_config('graphqlEndpoint')
graphql_secret = get_primehub_config('graphqlSecret')
fs_group_id = get_config('singleuser.fsGid')

autoscaling_enabled = get_config('scheduling.userScheduler.enabled')

phfs_enabled = get_primehub_config('phfsEnabled', False)
phfs_pvc = get_primehub_config('phfsPVC', '')

# Support old group volume convention.
support_old_group_volume_convention = os.environ.get(
    'SUPPORT_OLD_GROUP_VOLUME_CONVENTION', False) == "true"

# Uncomment below to setup prefix (e.g. Bearer) for API key, if needed
# configuration.api_key_prefix['authorization'] = 'Bearer'

BACKEND_API_UNAVAILABLE = 'API_UNAVAILABLE'
GRAPHQL_LAUNCH_CONTEXT_QUERY = '''query ($id: ID!) {
                    system { defaultUserVolumeCapacity }
                    user (where: { id: $id }) { id username isAdmin volumeCapacity
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
                            userVolumeCapacity
                            projectQuotaCpu
                            projectQuotaGpu
                            projectQuotaMemory
                            instanceTypes { name displayName description spec global }
                            images { name displayName description spec global }
                            datasets { name displayName description spec global writable mountRoot homeSymlink launchGroupOnly }
                        }
                } }'''


@gen.coroutine
def fetch_context(user_id):
    headers = {'Content-Type': 'application/json',
               'Authorization': 'Bearer %s' % graphql_secret}
    data = {'query': GRAPHQL_LAUNCH_CONTEXT_QUERY,
        'variables': {'id': user_id}}
    client = httpclient.AsyncHTTPClient(max_clients=64)
    response = yield client.fetch(graphql_endpoint,
                                  method='POST',
                                  headers=headers,
                                  body=json.dumps(data))
    result = json.loads(response.body.decode())

    # Code: `API_UNAVAILABLE` if kube-apiserver is down.
    if 'errors' in result:
        raise Exception(BACKEND_API_UNAVAILABLE)

    if 'data' in result:
        return result['data']
    return {}

class PrimehubOidcMixin(OAuth2Mixin):
    _OAUTH_AUTHORIZE_URL = '%s/realms/%s/protocol/openid-connect/auth' % (keycloak_url, realm)
    _OAUTH_ACCESS_TOKEN_URL = '%s/realms/%s/protocol/openid-connect/token' % (keycloak_url, realm)

class OIDCLoginHandler(OAuthLoginHandler, PrimehubOidcMixin):
    pass

class OIDCLogoutHandler(LogoutHandler):
    kc_logout_url = '%s/realms/%s/protocol/openid-connect/logout' % (
        keycloak_url, realm)

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

    @gen.coroutine
    def verify_access_token(self, user):
        auth_state = yield user.get_auth_state()
        access_token = auth_state['access_token']
        token_type = 'Bearer'

        # Determine who the logged in user is
        headers = {
            "Accept": "application/json",
            "User-Agent": "JupyterHub",
            "Authorization": "{} {}".format(token_type, access_token)
        }

        try:
            response = yield self.client.fetch(self.userdata_url,
                                        method='GET',
                                        headers=headers)
            if response.code == 200:
                return True
            else:
                return False
        except Exception as e:
            return False

    @gen.coroutine
    def refresh_user(self, user, handler=None):
        # prevent multiple graphql calls
        if isinstance(handler, (LoginHandler, GenericLoginHandler, OAuthCallbackHandler)):
            self.log.debug('skip refresh user in handler: %s', handler)
            return False

        self.log.debug('refresh user: %s', user)
        auth_state = yield user.get_auth_state()
        user_id = auth_state['oauth_user'].get('sub', None)
        if not user_id:
            self.log.debug('user id not found')
            return False

        is_valid_token = yield self.verify_access_token(user)
        if is_valid_token == False:
            self.log.debug('Expire access token: %s', user.name)
            return False

        try:
            updated_ctx = yield fetch_context(user_id)
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

    @gen.coroutine
    def is_admin(self, handler, authentication):
        return authentication['auth_state']['launch_context'].get(
            'isAdmin', False)

    @gen.coroutine
    def authenticate(self, handler, data=None):
        user = yield super().authenticate(handler, data)
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
            ctx = yield fetch_context(user_id)
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

    @gen.coroutine
    def attach_project_pvc(self, spawner, project, group, size):
        spawner.volumes.append({'name': 'project-' + project,
                                'persistentVolumeClaim': {'claimName': 'project-' + project}})
        spawner.volume_mounts.append(
            {'mountPath': '/project/' + project, 'name': 'project-' + project})

    @gen.coroutine
    def post_spawn_stop(self, user, spawner):
        self.log.debug("post spawn stop for %s", user)
        user.spawners.pop('')

    def get_custom_resources(self, namespace, plural):
        api_instance = shared_client('CustomObjectsApi')
        group = 'primehub.io'
        version = 'v1alpha1'

        api_response = api_instance.list_namespaced_custom_object(
            group, version, namespace, plural)
        return api_response['items']

    # logic of determing user volume capacity
    def user_volume_capacity(self, auth_state):
        default_capacity = auth_state.get('system', {}).get(
            'defaultUserVolumeCapacity', None)
        user_capacity = auth_state['launch_context'].get(
            'volumeCapacity', None)
        groups = auth_state['launch_context'].get('groups', [])
        group_capacities = [
            x.get(
                'userVolumeCapacity',
                None) for x in list(
                filter(
                    lambda x: x['name'] != 'everyone',
                    groups))]
        group_capacities = [x for x in group_capacities if x]

        if user_capacity:
            return user_capacity

        if group_capacities:
            return max(group_capacities)

        return default_capacity

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

        self.log.debug('Datasets in launch group [%s]: %s' % (spawner.user_options['group']['name'], datasets_in_launch_group))

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
                ds_env[env_key] = value

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

    @gen.coroutine
    def pre_spawn_start(self, user, spawner):
        """Pass upstream_token to spawner via environment variable"""
        auth_state = yield user.get_auth_state()

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
                'IMAGE_NAME': spawner.user_options.get('image', '')
            }
        )

        if spawner.extra_resource_limits.get('nvidia.com/gpu', 0) == 0 and not spawner.enable_kernel_gateway:
            spawner.environment.update({'NVIDIA_VISIBLE_DEVICES': 'none'})

        if start_notebook_config:
            spawner.volumes.append(
                {'name': 'start-notebook-d', 'config_map': {'name': start_notebook_config}})
            spawner.volume_mounts.append(
                {'mountPath': '/usr/local/bin/start-notebook.d', 'name': 'start-notebook-d'})

        self.chown_extra = []

        try:
            self.log.info("oauth_user %s" % auth_state['oauth_user'])
            namespace = os.environ.get('POD_NAMESPACE', 'hub')
            primehub_datasets = {
                item['metadata']['name']: item for item in self.get_custom_resources(
                    namespace, 'datasets')}
        except ApiException as e:
            print(
                "Exception when calling CustomObjectsApi->get_namespaced_custom_object: %s\n" %
                e)

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
                self.log.debug('[skip-info] :: (%s, %s)' % ('%sds:%s' % (role_prefix, name), '%sds:rw:%s' % (role_prefix, name)))
                continue
            mounted = self.mount_dataset(spawner, global_datasets, datasets_in_launch_group, name, dataset)
            self.log.debug(
                    "  %s dataset %s (type %s)", ('mounting' if mounted else 'skipped'), name, type)

        launch_group = spawner.user_options['group']['name']
        groups = auth_state['launch_context']['groups']

        if support_old_group_volume_convention:
            self.log.warn('Old group volume convention (Project-${group_name}) is deprecated as of PrimeHub v1.6.0. Use new group volume options instead.')
            for group in groups:
                [name, is_project] = re.subn('^[Pp]roject[-_]', '', group['name'])
                name = re.sub('_', '-', name).lower()
                if is_project:
                    yield self.attach_project_pvc(spawner, name, name, '200Gi')
                    self.chown_extra.append('/project/' + name)
                    self.symlinks.append('ln -sf /project/%s /home/jovyan/' % name)
        else:
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
                    yield self.attach_project_pvc(spawner, name, name, size)
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

        spawner.environment.update({
            'CHOWN_EXTRA': ','.join(self.chown_extra)
        })

        # use preStop hook to ensure jupyter's metadata owner back to the jovyan user
        spawner.lifecycle_hooks = {
            'postStart': {'exec': {'command': ['bash', '-c', ';'.join(self.symlinks)]}},
            'preStop': {'exec': {'command': ['bash', '-c', ';'.join(["chown -R 1000:100 /home/jovyan/.local/share/jupyter || true"])]}}
        }

        # add labels for resource validation
        spawner.extra_labels['primehub.io/user'] = escape_to_primehub_label(spawner.user.name)
        spawner.extra_labels['primehub.io/group'] = escape_to_primehub_label(spawner.user_options.get('group', {}).get('name', ''))

        # add annotations for billing, the value must be string
        spawner.extra_annotations['auditing.launch_id'] = uuid.uuid4().hex
        spawner.extra_annotations['auditing.pod_name'] = spawner.pod_name
        spawner.extra_annotations['auditing.user_name'] = spawner.user.name
        spawner.extra_annotations['auditing.launch_group_name'] = spawner.user_options.get('group', {}).get('name', '')
        spawner.extra_annotations['auditing.instance_type'] = spawner.user_options.get('instance_type', '')
        spawner.extra_annotations['auditing.image'] = spawner.image
        spawner.extra_annotations['auditing.cpu_limit'] = str(spawner.cpu_limit)
        spawner.extra_annotations['auditing.mem_limit'] = str(spawner.mem_limit)
        spawner.extra_annotations['auditing.gpu_limit'] = str(spawner.extra_resource_limits.get('nvidia.com/gpu', 0))

        spawner.init_containers = []
        self.mount_primehub_scripts(spawner)

        origin_args = spawner.get_args()
        def empty_list():
            return []
        spawner.get_args = empty_list
        spawner.cmd = ['/opt/primehub-start-notebook/primehub-entrypoint.sh'] + origin_args

        if spawner.enable_kernel_gateway:
            self.log.warning('enable kernel gateway')
            mutate_pod_spec_for_kernel_gateway(spawner)

        if spawner.enable_safe_mode:
            self.log.warning('enable safe mode')
            # rescue mode: change home-volume mountPath
            for m in spawner.volume_mounts:
                if m['mountPath'] == '/home/jovyan':
                    m['mountPath'] = '/home/jovyan/user'
            self.support_repo2docker(spawner)

        # In order to check it passed the admission, set a bad initcontainer and admission will remove this initcontainer.
        spawner.init_containers.append({
            "name": "admission-is-not-found",
            "image": "admission-is-not-found",
            "imagePullPolicy": "Never",
            "command": ["false"],
        })

        spawner.set_launch_group(launch_group)

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
    enable_kernel_gateway = None
    enable_safe_mode = False
    _launch_group = None
    _active_group = None

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
        result = {}

        # when kernel container is enabled,
        # resource settings should be set on the kernel container not the notebook container
        if self.enable_kernel_gateway:
            resources = dict(
                limits=dict(cpu=float(spec.get('limits.cpu', 1)), memory=spec.get('limits.memory', '1G')),
                requests=dict(cpu=float(spec.get('requests.cpu', 0)), memory=spec.get('requests.memory', '0G'))
            )
            if extra_resource_limits:
                resources['limits']['nvidia.com/gpu'] = gpu

            # FIXME instance_type_to_override shouldn't modify caller(spawner) directly
            # it is designed to return a partial state that can update to spawner
            self.kernel_container_resources = resources

            # when we enable the kernel container,
            # we wouldn't set up resources at notebook
            result = {
                'cpu_guarantee': None,
                'cpu_limit': None,
                'mem_limit': None,
                'mem_guarantee': None,
                'extra_resource_limits': {}
            }
        else:
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
        return [x for g in groups for x in g[key] if x['name']
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

    def get_state(self):
        """get the current state"""
        state = super().get_state()
        if self.launch_group:
            state['launch_group'] = self.launch_group
        self.log.info("get_state: %s" % self._launch_group)
        return state

    def load_state(self, state):
        """load state from the database"""
        super().load_state(state)
        if 'launch_group' in state:
            self._launch_group = state['launch_group']
        self.log.info("load_state: %s" % self._launch_group)

    def clear_state(self):
        """clear any state (called after shutdown)"""
        super().clear_state()
        self._launch_group = None
        self.log.info("clear_state: %s" % self._launch_group)

    @gen.coroutine
    def _render_options_form_dynamically(self, current_spawner):
        self.log.debug("render_options for %s", self._log_name)
        auth_state = yield self.user.get_auth_state()
        if not auth_state:
            raise Exception('no auth state')
        context = auth_state.get('launch_context', None)
        error = auth_state.get('error', None)

        if error == BACKEND_API_UNAVAILABLE:
            return self.render_html('spawn_block.html', block_msg='Backend API unavailable. Please contact admin.')

        if not context:
            return self.render_html('spawn_block.html', block_msg='Sorry, but you need to relogin to continue', href='/hub/logout')

        try:
            groups = self._groups_from_ctx(context)
            if self.active_group:
                groups = [group for group in groups if group.get('name') == self.active_group ]
                if len(groups) == 0:
                    return self.render_html('spawn_block.html', block_msg=f"The group {self.active_group} is not found")
            self._groups = groups
        except:
            return self.render_html('spawn_block.html', block_msg='No group is configured for you to launch a server. Please contact admin.')

        return self.render_html('groups.html', groups=groups, active_group=self.active_group, enable_kernel_gateway=enable_feature_kernel_gateway)

    def get_container_resource_usage(self, group):
        existing = []
        for pod in self.primehub_pod_reflector.pods.values():
            if pod.metadata.labels.get("primehub.io/group", "") == escape_to_primehub_label(group["name"]) and \
                (pod.status.phase == "Pending" or pod.status.phase == "Running"):
                existing += pod.spec.containers

        cpu, gpu, mem = (0, 0, 0)
        # some functions are under primehub_utils.py
        cpu = sum([float(convert_cpu_values_to_float(container.resources.limits.get('cpu', 0)))
                   for container in existing if container.resources.limits])
        gpu = sum([int(container.resources.limits.get('nvidia.com/gpu', 0))
                   for container in existing if container.resources.limits])
        mem = sum([int(convert_mem_resource_to_bytes(container.resources.limits.get('memory', 0)))
                   for container in existing if container.resources.limits])
        mem = round(float(mem / GiB()), 1) # convert to GB

        return {'cpu': cpu, 'gpu': gpu, 'memory': mem}

    def _groups_from_ctx(self, context):
        role_groups = [group for group in context['groups']
                       if group['name'] == 'everyone']

        filtered_groups = [group for group in context['groups']
                           if group.get('projectQuotaCpu', None) != 0 and
                           group.get('quotaCpu', None) != 0 and
                           group.get('projectQuotaMemory', None) != 0 and
                           group.get('quotaMemory', None) != 0]

        groups = [
            {
                **(group),
                **({
                    'images': self.merge_group_properties('images', [group] + role_groups),
                    'instanceTypes': self.merge_group_properties('instanceTypes', [group] + role_groups)
                }),
                'usage': self.get_container_resource_usage(group)
            } for group in filtered_groups]

        if not len(groups):
            raise Exception(
                'Not enough resource limit in your groups, please contact admin.')

        def map_group(group):
            if group.get('displayName', None) is None or group.get('displayName', None) is '': group['displayName'] = group.get('name', '')
            return group

        groups = list(map(map_group, groups))
        return groups

    def get_default_image(self):
        return self.config.get('KubeSpawner', {}).get('image', '')

    def options_from_form(self, formdata):
        if enable_feature_kernel_gateway:
            self.enable_kernel_gateway = formdata.get('kernel_gateway', ['off']) == ['on']
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
        return options

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

    @gen.coroutine
    def _start(self):
        try:
            # check only if autoscaling is not enabled
            if autoscaling_enabled != True:
                self.periodic_check_event_timer = tornado.ioloop.PeriodicCallback(self.check_event, 500)
                self.periodic_check_event_timer.start()

            result = yield super()._start()
            return result
        except ApiException as e:
            if e.status == 410: # only handle resources validation webhook
                self.log.error("Resources validation webhook: {}".format(e))
                json_body = json.loads(str(e).split("HTTP response body:")[1].replace("'", "\""))
                raise Exception(json_body['reason'])
            else:
                json_body = json.loads(str(e).split("HTTP response body:")[1].replace("'", "\""))

                # This is the temp workaround and wait for the fix from k8s: https://github.com/kubernetes/kubernetes/pull/72751
                if "admission webhook" in json_body['message'] and "resources-validation-webhook" in json_body["message"]:
                    raise Exception(json_body['message'].split("denied the request:")[1])

                raise Exception(json_body['message'])

    def check_event(self):
        if not hasattr(self, '_start_future'):
            self.log.debug(time.ctime())
            self.log.debug('check_event waits for _start_future')
            return
        start_future = self._start_future
        if not start_future.done():
            for event in self.events:
                if "Insufficient" in event.message and ("cpu" in event.message or "memory" in event.message or "gpu" in event.message):
                    self._start_future.set_exception(Exception(event.message))
                    self.stop()
                    self.periodic_check_event_timer.stop()
                    self.periodic_check_event_timer = None

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
        self.finish(dict(groups=groups))

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

        group = self.get_query_argument("group")
        if group and user.spawner:
            user.spawner.set_active_group(group)

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
        )
        self.finish(html)


def mutate_pod_spec_for_kernel_gateway(spawner):

    # patch it
    spawner.extra_pod_config = {
        "shareProcessNamespace": True
    }

    spawner.init_containers = [{
        "name": "chown",
        "image": "busybox",
        "imagePullPolicy": "IfNotPresent",
        "securityContext": {"runAsUser": 0},
        "volumeMounts": [
            {'mountPath': '/home/jovyan', 'name': 'volume-{username}'}
        ],
        "command": ["sh"],
        "args": ["-c", "chown 1000 /home/jovyan"]
    }]

    # overwrite default image
    user_launch_image = spawner.image
    spawner.extra_annotations['auditing.image'] = user_launch_image
    spawner.image = spawner.get_default_image()
    kernel_gateway_env = [{'name': 'JUPYTER_GATEWAY_ENV_WHITELIST', 'value': 'HOME'},
                          {'name': 'HOME', 'value': '/home/jovyan'}]

    if spawner.kernel_container_resources['limits'].get('nvidia.com/gpu', 0) == 0:
        kernel_gateway_env.append({'name': 'NVIDIA_VISIBLE_DEVICES', 'value': 'none'})

    spawner.extra_containers = [{
        "name": "kernel",
        "image": user_launch_image,
        "imagePullPolicy": "IfNotPresent",
        "securityContext": {"runAsUser": 0},
        "volumeMounts": spawner.volume_mounts,
        "lifecycle": spawner.lifecycle_hooks,
        "env": kernel_gateway_env,
        "command": ["/opt/primehub-start-notebook/kernel_gateway.sh"],
        "resources": spawner.kernel_container_resources
    }]

    spawner.environment['JUPYTER_GATEWAY_URL'] = 'http://127.0.0.1:8889'
    spawner.environment['JUPYTER_GATEWAY_VALIDATE_CERT'] = 'no'
    spawner.environment['LOG_LEVEL'] = 'DEBUG'
    spawner.environment['JUPYTER_GATEWAY_REQUEST_TIMEOUT'] = '40'
    spawner.environment['JUPYTER_GATEWAY_CONNECT_TIMEOUT'] = '40'
    spawner.environment['KERNEL_IMAGE'] = user_launch_image


if locals().get('c') and not os.environ.get('TEST_FLAG'):

    c = locals().get('c')

    if c.JupyterHub.log_level != 'DEBUG':
        c.JupyterHub.log_level = 'WARN'

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
            (r"/primehub/home", PrimeHubHomeHandler),
            ]

    c.JupyterHub.redirect_to_server = False
    c.JupyterHub.template_paths = [jupyterhub_template_path]
    c.JupyterHub.statsd_host = 'localhost'
    c.JupyterHub.statsd_port = 9125
    c.JupyterHub.statsd_prefix = 'jupyterhub'
    c.JupyterHub.authenticate_prometheus = False
    c.JupyterHub.template_vars = { 'primehub_version': primehub_version }
    c.JupyterHub.logo_file = '/usr/local/share/jupyterhub/static/images/PrimeHub.png'
    c.PrimeHubSpawner.start_timeout = 60 * 5
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
