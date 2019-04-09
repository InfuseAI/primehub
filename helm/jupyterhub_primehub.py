import urllib
from z2jh import get_config
from oauthenticator.generic import GenericOAuthenticator, OAuthLoginHandler
from tornado.auth import OAuth2Mixin
from tornado import gen

from jupyterhub.handlers import LogoutHandler

keycloak_url = os.environ['PRIMEHUB_KEYCLOAK_URL']
keycloak_realm = os.environ['PRIMEHUB_KEYCLOAK_REALM']
keycloak_client_id = os.environ['PRIMEHUB_KEYCLOAK_CLIENT_ID']
keycloak_client_secret = os.environ['PRIMEHUB_KEYCLOAK_CLIENT_SECRET']

scope_required = get_config('custom.scopeRequired')

class KeycloakMixin(OAuth2Mixin):
  _OAUTH_AUTHORIZE_URL = "%s/auth/realms/%s/protocol/openid-connect/auth" % (keycloak_url, keycloak_realm)
  _OAUTH_ACCESS_TOKEN_URL = "%s/auth/realms/%s/protocol/openid-connect/token" % (keycloak_url, keycloak_realm)

class PrimeHubLogoutHandler(LogoutHandler):
  kc_logout_url = '%s/auth/realms/%s/protocol/openid-connect/logout' % (keycloak_url, keycloak_realm)

  async def get(self):
    # redirect to keycloak logout url and redirect back with kc=true parameters
    # then proceed with the original logout method.
    logout_kc = self.get_argument('kc', '')
    if logout_kc != 'true':
      logout_url = self.request.full_url() + '?kc=true'
      self.redirect(self.kc_logout_url + '?' + urllib.parse.urlencode({ 'redirect_uri' : logout_url}))
    else:
      super().get()

class PrimeHubLoginHandler(OAuthLoginHandler, KeycloakMixin):
    pass


class PrimeHubAuthenticator(GenericOAuthenticator):
  client_id_env = 'PRIMEHUB_KEYCLOAK_CLIENT_ID'
  client_secret_env = 'PRIMEHUB_KEYCLOAK_CLIENT_SECRET'
  userdata_url = '%s/auth/realms/%s/protocol/openid-connect/userinfo' % (keycloak_url, keycloak_realm)
  userdata_method = 'GET'
  userdata_params = {'state': 'state'}
  username_key = 'preferred_username'
  scope = [ 'openid' ] + ([scope_required] if scope_required else [])
  auto_login = True

  token_url = KeycloakMixin._OAUTH_ACCESS_TOKEN_URL
  login_handler = PrimeHubLoginHandler
  logout_handler = PrimeHubLogoutHandler

  @gen.coroutine
  def authenticate(self, handler, data=None):
    user =  yield super().authenticate(handler, data)
    if not user:
      return
    self.log.debug("auth: %s", user['auth_state'])
    if scope_required and not scope_required in user['auth_state']['oauth_user']['roles']:
      return
    user_id = user['auth_state']['oauth_user'].get('sub', None)
    if user_id == None:
      self.log.debug('user id not found')
      return

    return user

  def get_handlers(self, app):
    return super().get_handlers(app) + [(r'/logout', self.logout_handler)]

  @gen.coroutine
  def pre_spawn_start(self, user, spawner):
      """Pass upstream_token to spawner via environment variable"""
      auth_state = yield user.get_auth_state()
      if not auth_state:
          raise Exception('auth state must be enabled')

      spawner.environment.update({'TZ': auth_state['oauth_user'].get('timezone', 'UTC')})

      if spawner.extra_resource_limits.get('nvidia.com/gpu', 0) == 0:
          spawner.environment.update({ 'NVIDIA_VISIBLE_DEVICES': 'none'})

      start_notebook_config = get_config('custom.startNotebookConfigMap')
      if start_notebook_config:
        spawner.volumes.append({'name': 'start-notebook-d', 'config_map': {'name': start_notebook_config } })
        spawner.volume_mounts.append({'mountPath': '/usr/local/bin/start-notebook.d', 'name': 'start-notebook-d'})


c.JupyterHub.authenticator_class = PrimeHubAuthenticator
c.JupyterHub.slow_stop_timeout = 30
c.JupyterHub.template_paths = ["/etc/jupyterhub/templates"]

c.JupyterHub.statsd_host = 'localhost'
c.JupyterHub.statsd_port = 9125
c.JupyterHub.statsd_prefix = 'jupyterhub'
