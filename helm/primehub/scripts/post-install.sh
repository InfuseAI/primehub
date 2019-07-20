#!/bin/bash
set -e

mkdir /data
cd /data

KUBECTL=/kubectl
EXEC="${KUBECTL} exec -n ${KEYCLOAK_NAMESPACE} ${KEYCLOAK_NAME} -- "

copy_script() {
  for file in $@
  do
    ${KUBECTL} -n ${KEYCLOAK_NAMESPACE} \
      cp $(readlink -f /scripts/${file}) ${KEYCLOAK_NAME}:./${file}
  done
}

remove_script() {
  for file in $@
  do
    ${EXEC} rm -f ${file}
  done
}

patch_secret() {
  KEY=$1
  VALUE=$2
  patch_data="{\"data\":{\"$KEY\":\"$(echo -n $VALUE | base64)\"}}"
  kubectl -n primehub patch secret primehub-secret -p $patch_data
}

exec_script() {
  $EXEC sh -c "
    DOMAIN=${PRIMEHUB_DOMAIN} \
    ADMIN=${PRIMEHUB_ADMIN} \
    ADMIN_PASSWORD=${PRIMEHUB_ADMIN_PASSWORD} \
    REALM=${PRIMEHUB_REALM} \
    USER=${PRIMEHUB_USER} \
    USER_PASSWORD=${PRIMEHUB_USER_PASSWORD} \
    CLIENT=${PRIMEHUB_CLIENT} \
    CLIENT_ADMIN=${PRIMEHUB_CLIENT_ADMIN} \
    CLIENT_ADMIN_SECRET=${PRIMEHUB_CLIENT_ADMIN_SECRET} \
    CLIENT_MAINTENANCE_PROXY=${PRIMEHUB_CLIENT_MAINTENANCE_PROXY} \
    bash bootstrap.sh
  "

  client_secret=$($EXEC cat client.secret)
  client_admin_secret=$($EXEC cat client-admin.secret)
  client_maintenance_proxy_secret=$($EXEC cat client-maintenance-proxy.secret)

  echo "get client_secret ${client_secret}"
  echo "get client_admin_secret ${client_admin_secret}"
  echo "get client_maintenance_proxy ${client_maintenance_proxy}"

  patch_secret keycloak.url http://${PRIMEHUB_DOMAIN}
  patch_secret keycloak.clientId ${PRIMEHUB_CLIENT}
  patch_secret keycloak.clientSecret ${client_secret}
  patch_secret keycloak.clientAdminId ${PRIMEHUB_CLIENT_ADMIN}
  patch_secret keycloak.clientAdminSecret ${client_admin_secret}
  patch_secret keycloak.clientMaintenanceProxyId ${PRIMEHUB_CLIENT_MAINTENANCE_PROXY}
  patch_secret keycloak.clientMaintenanceProxySecret ${client_maintenance_proxy_secret}
}

copy_script \
  bootstrap.sh \
  kc_util.source \
  client.json \
  client-admin.json client-admin-roles.json \
  client-maintenance-proxy.json
exec_script
remove_script \
  kc_util.source \
  bootstrap.sh \
  client.json client.secret \
  client-admin.json  client-admin.secret \
  client-maintenance-proxy.json  client-maintenance-proxy.secret

