if [[ -z ${KCADM:+x} ]]; then
  echo '$KCADM should be defined' >&2
  exit 1
fi

function print_section() {
  echo -e "\033[0;32m$1\033[0m"
}

function print_info() {
  echo -e "\033[0;90m$1\033[0m"
}

function print_error() {
  echo -e "\033[0;91m$1\033[0m"
}

############################################################
# Keycloak Utiltiies - All fuctions are idempotent.
function kc_login_master() {
    print_section "Login to keycloak by user $KC_USER"
    $KCADM config credentials \
      --server $KC_URL \
      --realm master \
      --user $KC_USER \
      --password $KC_PASSWORD
}

function kc_login() {
  if [[ -z ${ADMIN_UI_CLIENT_ID:+x} || -z ${ADMIN_UI_CLIENT_SECRET:+x} ]]; then
    kc_login_master
  else
    set +e
    print_section "Login to keycloak by service account $ADMIN_UI_CLIENT_ID"
    $KCADM config credentials \
        --server $KC_URL \
        --realm $KC_REALM \
        --client $ADMIN_UI_CLIENT_ID \
        --secret $ADMIN_UI_CLIENT_SECRET
    login_success=$?
    set -e
    if [ "$login_success" != "0" ]; then
      print_section "First time to setup $KC_REALM, fallback to login by user $KC_USER"
      kc_login_master
    fi
  fi
}

function kc_realm_create() {
  if [[ ! `$KCADM get realms/$KC_REALM 2> /dev/null` ]]; then
    $KCADM create realms \
      -s realm=$KC_REALM \
      -s enabled=true
  fi
}

function kc_realm_set_ssl_required() {
  local realm=$1
  local value=$2

  $KCADM update realms/$realm -s "sslRequired=$value"
}

function kc_user_id() {
  local realm=$1
  local user=$2

  local user_id=""

  local result=$(
    $KCADM get -r $realm users -q username=$user
  )

  local result_count=`echo $result | jq length`
  if (( $result_count != 0 )); then
    user_id=`echo $result | jq -r '.[0].id'`
  fi

  echo $user_id
}

function kc_user_delete() {
  local realm=$1
  local user=$2

  local user_id=$(kc_user_id $realm $user)
  if [[ user_id != "" ]]; then
    $KCADM delete users/$user_id -r $realm
  fi
}

function kc_user_create() {
  local prefix=$1
  local realm=$2
  local user=$3
  local password=$4
  local user_id

  local result=$(
    $KCADM get -r $realm users -q username=$user
  )

  local result_count=`echo $result | jq length`
  if (( $result_count == 0 )); then
    user_id=$(\
      $KCADM create users \
        -r $realm \
        -s username=$user \
        -s email=dev+$user@infuseai.io \
        -s enabled=true \
        -s emailVerified=true \
        --id \
      )
  else
    user_id=`echo $result | jq -r '.[0].id'`
  fi

  $KCADM set-password \
      -r $realm \
      --username $user \
      --new-password $password

  eval "${prefix}_USER_ID=$user_id"
  eval "${prefix}_USER=$user"
  eval "${prefix}_PASSWORD=$password"
}

function kc_user_group_add() {
  local realm=$1
  local user=$2
  local group=$3
  $KCADM add-members -r $realm --uusername $user --gname $group
}

function kc_user_become_group_admin() {
  local realm=$1
  local user=$2
  local group=$3
  local default_group_id=$(kc_group_id $realm $group)
  echo $KCADM update groups/$default_group_id -r $realm -s 'attributes.admins=["'$user'"]'
  $KCADM update groups/$default_group_id -r $realm -s 'attributes.admins=["'$user'"]'
}

function kc_user_add_client_role() {
  local realm=$1
  local user=$2
  local client=$3
  local role=$4

  $KCADM add-roles \
      -r $realm \
      --uusername ${user} \
      --cclientid $client \
      --rolename $role
}

function kc_group_create() {
  local prefix=$1
  local realm=$2
  local group=$3
  local group_file=${4:-''}

  local groups=`$KCADM get groups -r $realm -c`
  local group_id=$(echo $groups | jq -r ".[] | select(.name==\"${group}\") | .id")

  if [[ -z ${group_id:+x} ]]; then
    if [[ -z $group_file ]]; then
      group_id=$(\
        $KCADM create groups \
          -r $realm \
          -s name=$group \
          --id \
      )
    else
      group_id=$(\
        $KCADM create groups \
          -r $realm \
          -s name=$group \
          --id \
          -f -\
        < $group_file
      )
    fi
  fi

  eval "${prefix}_ID=$group_id"
}

function kc_group_update() {
  local realm=$1
  local group_id=$2
  local setting=$3
  $KCADM update groups/$group_id -s $setting -r $realm
}

function kc_group_default() {
  local realm=$1
  local group_id=$2

  $KCADM update realms/$realm/default-groups/$group_id
}

function kc_group_id() {
  local realm=$1
  local group=$2

  $KCADM get-group -r $realm --name $group --id
}

function kc_group_add_realm_role() {
  local realm=$1
  local group=$2
  local role=$3

  $KCADM add-roles \
      -r $realm \
      --gname $group \
      --rolename $role
}

function kc_client_id {
  local realm=$1
  local client=$2

  local result=$(
    $KCADM get -r $realm clients -q clientId=$client
  )

  local result_count=`echo $result | jq length`
  if (( $result_count > 0 )); then
    echo $result | jq -r '.[0].id'
  fi
}

function kc_client_get() {
  local realm=$1
  local client=$2

  $KCADM get -r $realm clients -q clientId=$client | jq .[]
}

function kc_client_get_secret() {
  local realm=$1
  local client=$2

  client_id=$(kc_client_id $realm $client)
  $KCADM get -r $realm clients/${client_id}/client-secret | jq -r '.value'
}

function kc_client_create() {
  local prefix=$1
  local realm=$2
  local client=$3
  local redirect_uri=$4
  local client_file=$5

  local client_id=$(kc_client_id $realm $client)
  if [[ -z $client_id ]]; then
    client_id=$(\
      $KCADM create clients \
        -r $realm \
        -s clientId=$client \
        -s "redirectUris+=$redirect_uri" \
        -f - \
        --id \
    < $client_file)
  fi
  client_secret=$($KCADM get "clients/$client_id/client-secret" -r $realm | jq -r .value)

  eval "${prefix}_ID=$client_id"
  eval "${prefix}_NAME=$client"
  eval "${prefix}_SECRET=$client_secret"
}

function kc_client_update() {
  local realm=$1
  local client_id=$2
  local client_file=$3

  if [[ -z $client_id ]]; then
    $KCADM update "clients/$client_id" \
      -r $realm \
      -f - \
      < $client_file
  fi
}

function kc_client_add_protocol_mappers() {
  local realm=$1
  local client_id=$2
  local mapper=$3

  if [[ ! -z $client_id ]]; then
    ( $KCADM create "clients/$client_id/protocol-mappers/models" \
      -r $realm \
      -b "$mapper" 2> /dev/null || print_info "Mapper already exist" )
  fi
}

function kc_client_add_mapper() {
  local realm=$1
  local client_id=$2
  local mapper=$3

  $KCADM create "clients/$client_id/protocol-mappers/models" -r $realm -b "$mapper" 2> /dev/null
}

function kc_client_add_redirect_uri() {
  local realm=$1
  local client_id=$2
  local redirect_uri=$3

  $KCADM update "clients/$client_id" \
      -r $realm \
      -s "redirectUris+=${redirect_uri}"
}

function kc_client_add_client_scope {
  local realm=$1
  local client=$2
  local target_client=$3
  local role=$4


  client_id=$(kc_client_id $realm $client)
  target_client_id=$(kc_client_id $realm $target_client)


  # target client id
  local role_body=$(
    $KCADM get -r $realm "clients/${client_id}/scope-mappings/clients/${target_client_id}/available" \
      | jq -c '. | map(select(.name=="realm-admin"))'
  )

  echo "$role_body" \
    | $KCADM create -r $realm "clients/${client_id}/scope-mappings/clients/${target_client_id}" -f -
}

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

function kc_role_create() {
  local prefix=$1
  local realm=$2
  local role=$3

  local roles=`$KCADM get roles -r $realm -c`
  local role_id=$(echo "$roles" | jq -r ".[] | select(.name==\"${role}\") | .id")

  if [[ -z ${role_id:+x} ]]; then
    $KCADM create roles \
      -r $realm \
      -s name=$role \
      --id

    roles=`$KCADM get roles -r $realm -c`
    role_id=$(echo "$roles" | jq -r ".[] | select(.name==\"${role}\") | .id")
  fi

  eval "${prefix}_ID=$role_id"
}

##### Idempotent Functions
function kc_apply_client() {
  local realm=$1
  local client=$2
  local client_file=$3

  if [[ $# -gt 3 ]]; then
    local redirect_uri=$4
  fi
  print_info "[client/$client] apply client"

  # Get client data
  local client_data=$(kc_client_get $realm $client)
  if [[ -z $client_data ]]; then
    # create if not exists
    print_info "[client/${client}] create client"

    client_data=$("$KCADM" create clients \
    -r "$realm" \
    -s "clientId=$client" \
    -f "$client_file" \
    --output)
  fi
  local client_id=$(echo $client_data | jq -r .id)

  # Add protocol mappers
  for mapper in $(cat $client_file | jq -c '.protocolMappers // [] | .[]'); do
    local mapper_name=$(echo "$mapper" | jq -r .name)
    local len=$(echo "$client_data" | jq ".protocolMappers // [] | map(select(.name == \"${mapper_name}\")) | length")
    if [[ $len == '0' ]]; then
      print_info "[client/${client}] add protocol mapper $mapper_name"
      kc_client_add_protocol_mappers $realm $client_id "$mapper"
    fi
  done

  # Add redirect uris
  if [[ -n $redirect_uri ]]; then
    local len=$(echo $client_data | jq ".redirectUris // [] | map(select(. == \"${redirect_uri}\")) | length")
    if [[ $len == '0' ]]; then
      print_info "[client/${client}] add redirect-uri $redirect_uri"
      kc_client_add_redirect_uri $realm $client_id $redirect_uri
    fi
  fi
}

function kc_apply_user_roles() {
  local realm=$1
  local username=$2
  local role_file=$3
  local client
  local role
  print_info "[user/$username] apply roles"

  # realm roles
  for role in $(jq -r ".realmRoles // [] | .[]" $role_file); do
    print_info "[user/$username] add role $role"
    $KCADM add-roles \
      -r $realm \
      --uusername $username \
      --rolename $role
  done

  # client roles
  for client in $(jq -r '.clientRoles // [] | keys | .[]' $role_file); do
    for role in $(jq -r ".clientRoles[\"${client}\"][]" $role_file); do
      print_info "[user/$username] add role ${client}/${role}"
      $KCADM add-roles \
        -r $realm \
        --uusername $username \
        --cclientid $client \
        --rolename $role
    done
  done
}

function kc_apply_client_scopes() {
  local realm=$1
  local client=$2
  local role_file=$3
  local role
  local roleclient
  print_info "[client/$client] apply scopes"

  # realm roles
  for role in $(jq -r ".realmRoles // [] | .[]" $role_file); do
    print_info "[client/$client] add realm role $role"
    $KCADM add-scopes \
      -r $realm \
      --clientid $username \
      --rolename $role
  done

  # client roles
  for roleclient in $(jq -r '.clientRoles // [] | keys | .[]' $role_file); do
    for role in $(jq -r ".clientRoles[\"${roleclient}\"][]" $role_file); do
      print_info "[client/$client] add client role ${roleclient}/${role}"
      $KCADM add-scopes \
        -r $realm \
        --clientid $client \
        --roleclientid $roleclient \
        --rolename $role
    done
  done
}

function kc_theme_update() {
  local realm=$1
  local theme=$2
  local realmdata=$($KCADM get realms/$realm)

  # Check if the theme has been applied
  if [[ \
    $(echo "$realmdata" | jq -r .loginTheme) == $theme &&\
    $(echo "$realmdata" | jq -r .accountTheme) == $theme &&\
    $(echo "$realmdata" | jq -r .adminTheme) == $theme &&\
    $(echo "$realmdata" | jq -r .emailTheme) == $theme ]]
  then
    print_info "[realm/$realm] theme $theme has been applied. Skip apply theme."
    return
  fi

  # Check if the theme is available in keycloak
  if ! $KCADM get serverinfo | jq -r .themes.login[].name | grep -q $theme; then
    print_info "[realm/$realm] theme $theme not found. Skip apply theme"
    return
  fi

  print_info "[realm/$realm] apply theme $theme"
  $KCADM update realms/$realm \
    -s "loginTheme=$theme" \
    -s "accountTheme=$theme" \
    -s "adminTheme=$theme" \
    -s "emailTheme=$theme" || true
}

