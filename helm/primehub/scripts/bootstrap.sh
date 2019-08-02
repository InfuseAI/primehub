set -e

KCADM=keycloak/bin/kcadm.sh

source ./kc_util.source

# login
if [[ -z "${CLIENT_ADMIN_SECRET}" ]]; then
  # install
  echo "Login by user: $ADMIN"
  ${KCADM} config credentials --server http://localhost:8080/auth --realm master --user ${ADMIN} --password ${ADMIN_PASSWORD}
  ${KCADM} create realms -s realm=${REALM} -s enabled=true
else
  # upgrade
  echo "Login by service account: $CLIENT_ADMIN"
  ${KCADM} config credentials --server http://localhost:8080/auth --realm ${REALM} --client ${CLIENT_ADMIN} --secret ${CLIENT_ADMIN_SECRET}
fi

# keycloak client 'jupyterhub'
apply_client $CLIENT ./client.json "http://${DOMAIN}/*"
CLIENT_ID=$(kc_client_get $CLIENT | jq -r .id)
echo $(kc_client_secret ${CLIENT_ID}) > client.secret

# keycloak client 'primehub'
apply_client $CLIENT_ADMIN ./client-admin.json
apply_client_role $CLIENT_ADMIN ./client-admin-roles.json
CLIENT_ADMIN_ID=$(kc_client_get $CLIENT_ADMIN | jq -r .id)
echo $(kc_client_secret ${CLIENT_ADMIN_ID}) > client-admin.secret

# keycloak clinet 'maintenance proxy'
apply_client $CLIENT_MAINTENANCE_PROXY ./client-maintenance-proxy.json "http://${DOMAIN}${CLIENT_MAINTENANCE_PROXY_BASE_URL}/*"
CLIENT_MAINTENANCE_PROXY_ID=$(kc_client_get $CLIENT_MAINTENANCE_PROXY | jq -r .id)
echo $(kc_client_secret ${CLIENT_MAINTENANCE_PROXY_ID}) > client-maintenance-proxy.secret

# user
apply_user $USER $USER_PASSWORD
