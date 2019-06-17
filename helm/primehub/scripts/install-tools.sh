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

exec_script() {
  $EXEC sh -c "DOMAIN=${PRIMEHUB_DOMAIN} ADMIN=${PRIMEHUB_ADMIN} ADMIN_PASSWORD=${PRIMEHUB_ADMIN_PASSWORD} REALM=${PRIMEHUB_REALM} USER=${PRIMEHUB_USER} USER_PASSWORD=${PRIMEHUB_USER_PASSWORD} CLIENT=${PRIMEHUB_CLIENT} CLIENT_ADMIN=${PRIMEHUB_CLIENT_ADMIN} CLIENT_ADMIN_SECRET=${PRIMEHUB_CLIENT_ADMIN_SECRET} bash bootstrap.sh"

  # check if primehub-secret exits
  if ! (${KUBECTL} -n ${KEYCLOAK_NAMESPACE} get secret primehub-secret >/dev/null 2>&1); then
    client_secret=$($EXEC cat client.secret)
    client_admin_secret=$($EXEC cat client-admin.secret)
    echo "get client_secret ${client_secret}"
    echo "get client_admin_secret ${client_admin_secret}"

    ${KUBECTL} create -n ${KEYCLOAK_NAMESPACE} secret generic primehub-secret \
      --from-literal=keycloak.url=http://id.${PRIMEHUB_DOMAIN} \
      --from-literal=keycloak.clientId=${PRIMEHUB_CLIENT} \
      --from-literal=keycloak.clientSecret=${client_secret} \
      --from-literal=keycloak.clientAdminId=${PRIMEHUB_CLIENT_ADMIN} \
      --from-literal=keycloak.clientAdminSecret=${client_admin_secret}
  fi
}

copy_script bootstrap.sh kc_util.source client.json client-admin.json client-admin-roles.json
exec_script
remove_script \
  kc_util.source \
  bootstrap.sh \
  client.json client.secret \
  client-admin.json  client-admin.secret

exit 0
