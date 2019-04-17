#!/bin/bash

SCRIPTS_ROOT=$(dirname "${BASH_SOURCE[0]}"); source $SCRIPTS_ROOT/common.sh

CHART_ROOT=$(dirname "${BASH_SOURCE[0]}")/../helm
pushd $CHART_ROOT

kubectl exec -ti -n primehub primehub-keycloak-0 -- keycloak/bin/kcadm.sh  config credentials --server http://localhost:8080/auth  --realm master --user keycloak --password CHANGEKEYCLOAKPASSWORD
kubectl exec -ti -n primehub primehub-keycloak-0 -- keycloak/bin/kcadm.sh  create realms -s realm=primehub -s enabled=true

client_id=$(kubectl exec -ti -n primehub primehub-keycloak-0 -- keycloak/bin/kcadm.sh  create clients -r primehub -s clientId=jupyterhub -s "redirectUris+=http://hub.${DOMAIN}/*" -f - --id < ./primehub/keycloak/client-jupyterhub.json)

echo "client_id: $client_id"

kubectl exec -ti -n primehub primehub-keycloak-0 -- keycloak/bin/kcadm.sh  create users -r primehub -s username=phuser -s enabled=true -s emailVerified=true
kubectl exec -ti -n primehub primehub-keycloak-0 -- keycloak/bin/kcadm.sh  set-password  -r primehub --username phuser --new-password=randstring

client_secret=$(kubectl exec -ti -n primehub primehub-keycloak-0 -- keycloak/bin/kcadm.sh get clients/$client_id/client-secret -r primehub  | jq -r .value)

kubectl create -n primehub secret generic primehub-secret --from-literal=keycloak.url=http://id.${DOMAIN} --from-literal=keycloak.clientSecret=$client_secret

# for testing, set realm sslRequired=none
# also set the user to admin in keycloak
# export KCADM="kubectl exec -ti -n primehub primehub-keycloak-0 -- keycloak/bin/kcadm.sh"
# $KCADM add-roles -r primehub --uusername phuser --cclientid realm-management --rolename realm-admin

echo Hub: hub.${DOMAIN}
echo keycloak: id.${DOMAIN}/auth/admin/primehub/console

popd
