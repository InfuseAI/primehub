KCADM=keycloak/bin/kcadm.sh
KC_ADD_USER=keycloak/bin/add-user-keycloak.sh

# parameters for bootstraping
DOMAIN={{ .Values.primehub.domain }}
ADMIN=keycloak
ADMIN_PASSWORD=CHANGEKEYCLOAKPASSWORD
REALM={{ .Values.primehub.keycloak.realm}}
USER={{ .Values.primehub.user}}
USER_PASSWORD={{ .Values.primehub.password}}
CLIENT={{ .Values.primehub.keycloak.client}}

# FIXME: this wouldn't work without restart the server
# CAUTION: keycloak will lost data after helm-upgrade in non-persist deployment

# check keycloak initialized
#if [ "$(${KCADM} get users | jq '. | length')" == "" ]; then
#  echo "keycloak has not initialized, create an admin account"
#  ${KC_ADD_USER} -u ${ADMIN} -p ${ADMIN_PASSWORD}
#fi

# login
${KCADM} config credentials --server http://localhost:8080/auth --realm master --user ${ADMIN} --password ${ADMIN_PASSWORD}

echo "create realm if not exists"
if [ ! "$(${KCADM} get realms | jq "[.[] | select(.realm | contains(\"${REALM}\"))] | length")" == 1 ]; then
  echo "create realm ${REALM}"
  ${KCADM} create realms -s realm=${REALM} -s enabled=true
else
  echo "found realm ${REALM}"
fi

echo "create client if not exists"
if [ ! "$(${KCADM} get clients -r ${REALM} | jq "[.[] | select(.clientId | contains(\"${CLIENT}\"))] | length")" == 1 ]; then
  echo "create client ${CLIENT}"
  CLIENT_ID=$(${KCADM} create clients -r ${REALM} -s clientId=${CLIENT} -s "redirectUris+=http://hub.${DOMAIN}/*" -f - --id < ./body.json)
else
  echo "found client ${CLIENT}"
  CLIENT_ID=$(${KCADM} get clients -r ${REALM} | jq -r ".[] | select(.clientId | contains(\"${CLIENT}\")) | .id")
fi

echo "create user if not exists"
if [ ! "$(${KCADM} get users -r ${REALM} | jq "[.[] | select(.username | contains(\"${USER}\"))] | length")" == 1 ]; then
  echo "create user ${USER}"
  ${KCADM} create users -r ${REALM} -s username=${USER} -s enabled=true -s emailVerified=true
  ${KCADM} set-password  -r ${REALM} --username ${USER} --new-password=${USER_PASSWORD}
else
  echo "found user ${USER}"
fi


CLIENT_SECRET=$(${KCADM} get clients/${CLIENT_ID}/client-secret -r ${REALM} | jq -r .value)
echo ${CLIENT_SECRET} > client.secret
