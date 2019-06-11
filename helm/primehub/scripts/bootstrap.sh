set -e

KCADM=keycloak/bin/kcadm.sh
KC_ADD_USER=keycloak/bin/add-user-keycloak.sh


function kc_service_account_add_client_role() {
  local realm=$1
  local service_account=$2
  local client=$3
  local role=$4

  $KCADM add-roles \
      -r $realm \
      --uusername service-account-${service_account} \
      --cclientid $client \
      --rolename $role
}

# FIXME: this wouldn't work without restart the server
# CAUTION: keycloak will lost data after helm-upgrade in non-persist deployment

# check keycloak initialized
#if [ "$(${KCADM} get users | jq '. | length')" == "" ]; then
#  echo "keycloak has not initialized, create an admin account"
#  ${KC_ADD_USER} -u ${ADMIN} -p ${ADMIN_PASSWORD}
#fi

# login

if [[ -z ${CLIENT_ADMIN_SECRET} ]]; then
  # install
  echo "Login by user: $ADMIN"
  ${KCADM} config credentials --server http://localhost:8080/auth --realm master --user ${ADMIN} --password ${ADMIN_PASSWORD}
  ${KCADM} create realms -s realm=${REALM} -s enabled=true  
else
  # upgrade
  echo "Login by service account: $CLIENT_ADMIN"
  ${KCADM} config credentials --server http://localhost:8080/auth --realm ${REALM} --client ${CLIENT_ADMIN} --secret ${CLIENT_ADMIN_SECRET}
fi 

echo "create client if not exists"
if [ ! "$(${KCADM} get clients -r ${REALM} | jq "[.[] | select(.clientId | contains(\"${CLIENT}\"))] | length")" == 1 ]; then
  echo "create client ${CLIENT}"
  CLIENT_ID=$(${KCADM} create clients -r ${REALM} -s clientId=${CLIENT} -s "redirectUris+=http://hub.${DOMAIN}/*" -f - --id < ./client.json)
else
  echo "found client ${CLIENT}"
  CLIENT_ID=$(${KCADM} get clients -r ${REALM} | jq -r ".[] | select(.clientId | contains(\"${CLIENT}\")) | .id")
fi

echo "create admin client if not exists"
if [ ! "$(${KCADM} get clients -r ${REALM} | jq "[.[] | select(.clientId | contains(\"${CLIENT_ADMIN}\"))] | length")" == 1 ]; then
  echo "create client ${CLIENT_ADMIN}"
  CLIENT_ADMIN_ID=$(${KCADM} create clients -r ${REALM} -s clientId=${CLIENT_ADMIN} -f - --id < ./client-admin.json)
else
  echo "found client ${CLIENT_ADMIN}"
  CLIENT_ADMIN_ID=$(${KCADM} get clients -r ${REALM} | jq -r ".[] | select(.clientId | contains(\"${CLIENT_ADMIN}\")) | .id")
fi
kc_service_account_add_client_role ${REALM} ${CLIENT_ADMIN} realm-management realm-admin

echo "create user if not exists"
if [ ! "$(${KCADM} get users -r ${REALM} | jq "[.[] | select(.username | contains(\"${USER}\"))] | length")" == 1 ]; then
  echo "create user ${USER}"
  ${KCADM} create users -r ${REALM} -s username=${USER} -s enabled=true -s emailVerified=true
  ${KCADM} set-password  -r ${REALM} --username ${USER} --new-password=${USER_PASSWORD}
else
  echo "found user ${USER}"
fi


CLIENT_SECRET=$(${KCADM} get clients/${CLIENT_ID}/client-secret -r ${REALM} | jq -r .value)
CLIENT_ADMIN_SECRET=$(${KCADM} get clients/${CLIENT_ADMIN_ID}/client-secret -r ${REALM} | jq -r .value)
echo ${CLIENT_SECRET} > client.secret
echo ${CLIENT_ADMIN_SECRET} > client-admin.secret
