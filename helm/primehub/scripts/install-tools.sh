mkdir /data
cd /data

wget https://storage.googleapis.com/kubernetes-release/release/v1.14.1/bin/linux/amd64/kubectl -O kubectl
chmod a+x kubectl

KUBECTL=./kubectl
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
  $EXEC bash bootstrap.sh
  client_secret=$($EXEC cat client.secret)
  echo "get client_secret ${client_secret}"
  DOMAIN={{ .Values.primehub.domain }}
  ${KUBECTL} create -n primehub secret generic primehub-secret --from-literal=keycloak.url=http://id.${DOMAIN} --from-literal=keycloak.clientSecret=$client_secret
}


copy_script bootstrap.sh body.json
exec_script
remove_script bootstrap.sh body.json client.secret

