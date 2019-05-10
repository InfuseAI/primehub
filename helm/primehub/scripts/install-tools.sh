mkdir /data
cd /data

KUBECTL=/kubectl
EXEC="${KUBECTL} exec -ti -n ${KEYCLOAK_NAMESPACE} ${KEYCLOAK_NAME} -- "

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
  $EXEC sh -c "DOMAIN=${PRIMEHUB_DOMAIN} ADMIN=${PRIMEHUB_ADMIN} ADMIN_PASSWORD=${PRIMEHUB_ADMIN_PASSWORD} REALM=${PRIMEHUB_REALM} USER=${PRIMEHUB_USER} USER_PASSWORD=${PRIMEHUB_USER_PASSWORD} CLIENT=${PRIMEHUB_CLIENT} bash bootstrap.sh"
  client_secret=$($EXEC cat client.secret)
  echo "get client_secret ${client_secret}"
  ${KUBECTL} create -n primehub secret generic primehub-secret --from-literal=keycloak.url=http://id.${PRIMEHUB_DOMAIN} --from-literal=keycloak.clientSecret=$client_secret
}


copy_script bootstrap.sh body.json
exec_script
remove_script bootstrap.sh body.json client.secret

exit 0
