#!/usr/bin/env bash
set -euo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
KCADM=kcadm
source ${DIR}/keycloak.inc

KCADM_CONFIG=$HOME/.keycloak/kcadm.config
KUBECTL_DRY_RUN_FLAG='--dry-run=client'

############################################################
# Prepare
function prepare() {
  print_section "Kubectl version"
  kubectl version --client=true -o yaml
  kubectl_version=$(kubectl version --client -o json | jq -r '.clientVersion | .major +"."+ .minor')
  if [[ $kubectl_version < '1.18' ]]; then
    KUBECTL_DRY_RUN_FLAG='--dry-run'
  fi
}


############################################################
# Wait for keycloak
function wait_for_url() {
  local now=$SECONDS
  local timeout=900
  local url=$1
  local status

  while true; do
    if status=$(curl -L -s -o /dev/null --connect-timeout 10 --max-time 10 -w "%{http_code}" $url); then
      print_info "[$status] $url"
      if [[ $status =~ [23].. ]]; then
        break
      fi

      if (( $SECONDS - now > $timeout )); then
        print_info "timeout ${timeout}s"
        return 1
      fi
    else
      print_info "[xxx] ${url}"
    fi

    sleep 5;
  done;
}

function wait_for_keycloak() {
  print_section "Wait for keycloak ready..."
  wait_for_url $KC_URL
}

############################################################
# Idempotent update the keycloak
function update() {
  print_section "Update keycloak..."
  update_realm
  update_group_everyone
  update_client_admin_ui
  update_client_jupyterhub
  update_client_maintenance_proxy
  update_theme
}

function update_realm() {
  # Create realm: primehub
  if ! $KCADM get realms/$KC_REALM 2&>1 > /dev/null; then
    print_info "Create realm: $KC_REALM"
    $KCADM create realms \
      -s realm=$KC_REALM \
      -s enabled=true
  fi

  frontendUrl=$($KCADM get realms/$KC_REALM | jq -r ".attributes.frontendUrl")
  if [[ $frontendUrl != ${KC_APP_URL} ]]; then
    print_info "Update realm frontend URL: ${KC_APP_URL}"
    $KCADM update realms/$KC_REALM -s "attributes.frontendUrl=${KC_APP_URL}"
    if [[ -f $KCADM_CONFIG && $(jq -r ".realm" $KCADM_CONFIG) != "master" ]]; then
      print_info "Frontend URL changed by service account. Login again"
      kc_login
    fi
  fi

  if [[ -n ${KC_SSL_REQUIRED:-""} ]]; then
    print_info "Update realm ssl_required: ${KC_SSL_REQUIRED}"
    $KCADM update realms/$KC_REALM -s "sslRequired=${KC_SSL_REQUIRED}"
  fi

  if [[ ${KC_EULA_ENABLED:-false} == "true" ]]; then
    print_info "Enable End-User License Agreement"
    kc_terms_and_conditions $KC_REALM
  fi
}

function update_group_everyone() {
  local group=everyone
  local group_id=$($KCADM get groups -r $KC_REALM | jq -r ".[] | select(.name == \"${group}\") | .id")

  if [[ -z ${group_id:+x} ]]; then
    print_info "Create group: ${group}"
    kc_group_create PH_GROUP_EVERYONE $KC_REALM everyone ${DIR}/group-everyone.json
    kc_group_default $KC_REALM $PH_GROUP_EVERYONE_ID
  else
    PH_GROUP_EVERYONE_ID=$(kc_group_id $KC_REALM $group)
  fi
}

function update_client_admin_ui() {
  local client=$ADMIN_UI_CLIENT_ID
  local redirect_uri=$ADMIN_UI_REDIRECT_URI
  local client_file=$DIR/client-admin-ui.json
  local secret_name=primehub-client-admin-ui

  kc_apply_client $KC_REALM $client $client_file $redirect_uri
  kc_apply_user_roles $KC_REALM "service-account-$client" $DIR/role-realm-admin.json
  kc_apply_client_scopes $KC_REALM $client $DIR/role-realm-admin.json

  local client_secret=$(kc_client_get_secret $KC_REALM $client)
  kubectl -n "$PRIMEHUB_NAMESPACE" create secret generic $secret_name \
    --from-literal=client_id=$client \
    --from-literal=client_secret=$client_secret \
    --from-literal=everyone_group_id=$PH_GROUP_EVERYONE_ID \
    $KUBECTL_DRY_RUN_FLAG -oyaml | \
    kubectl apply -f -

  kc_apply_client_baseurl $KC_REALM $client $ADMIN_UI_BASEURL
}

function update_client_jupyterhub() {
  local client=$JUPYTERHUB_CLIENT_ID
  local redirect_uri=$JUPYTERHUB_REDIRECT_URI
  local client_file=$DIR/client-jupyterhub.json
  local secret_name=primehub-client-jupyterhub
  kc_apply_client $KC_REALM $client $client_file $redirect_uri

  local client_secret=$(kc_client_get_secret $KC_REALM $client)
  kubectl -n "$PRIMEHUB_NAMESPACE" create secret generic $secret_name \
    --from-literal=client_id=$client \
    --from-literal=client_secret=$client_secret \
    $KUBECTL_DRY_RUN_FLAG -oyaml | \
    kubectl apply -f -
}

function update_client_maintenance_proxy() {
  local client=$MAINTENANCE_PROXY_CLIENT_ID
  local redirect_uri=$MAINTENANCE_PROXY_REDIRECT_URI
  local client_file=$DIR/client-maintenance-proxy.json
  local secret_name=primehub-client-admin-notebook

  # Check keycloak version
  keycloak_version=$($KCADM get serverinfo | jq -r ".systemInfo.version")
  if [[ "$keycloak_version" =~ ^8.* ]]; then
    # To upgrade keycloak to v8.0.1, keycloak-gatekeeper need to fix 'aud' claim
    # ref: https://stackoverflow.com/questions/53550321/keycloak-gatekeeper-aud-claim-and-client-id-do-not-match
    # Currently, only maintenance-proxy uses keycloak-gatekeeper
    client_file=$DIR/client-maintenance-proxy-keycloak-8.json
  fi

  kc_apply_client $KC_REALM $client $client_file $redirect_uri

  local client_secret=$(kc_client_get_secret $KC_REALM $client)
  local proxy_encrypted_key=$(echo -n $client_secret | sha1sum| cut -c -32)

  kubectl -n "$PRIMEHUB_NAMESPACE" create secret generic $secret_name \
    --from-literal=client_id=$client \
    --from-literal=client_secret=$client_secret \
    --from-literal=proxy_encrypted_key=$proxy_encrypted_key \
    $KUBECTL_DRY_RUN_FLAG -oyaml | \
    kubectl apply -f -
}

function update_theme() {
  local default_theme="primehub"
  kc_theme_update $KC_REALM $default_theme
}

############################################################
# Create default resources.
#
# This is only triggered when no user in the realm
function create_default_resources() {
  local usercount=$($KCADM get -r $KC_REALM users | jq -r '. | length')
  if (( $usercount > 0 )); then
    print_section "Skip default resources"
    return 0
  fi

  print_section "Create default resources..."
  PH_USER=${PH_USER:-phadmin}
  PH_GROUP=${PH_GROUP:-phusers}
  PH_PASSWORD=${PH_PASSWORD:-$(openssl rand -hex 12)}
  PH_USER_EMAIL=${PH_USER_EMAIL:-"$PH_USER@example.com"}
  PH_USER_ENFORCE_UPDATE_PASSWORD=${PH_USER_ENFORCE_UPDATE_PASSWORD:-false}
  KC_EULA_ENABLED=${KC_EULA_ENABLED:-false}

  # Create user: phadmin
  print_info "Create user: $PH_USER email: $PH_USER_EMAIL"
  print_info "Enforce Update Password: $PH_USER_ENFORCE_UPDATE_PASSWORD"
  kc_user_create PH_ADMIN $KC_REALM $PH_USER $PH_PASSWORD $PH_USER_EMAIL $PH_USER_ENFORCE_UPDATE_PASSWORD $KC_EULA_ENABLED

  # Create group: phusers
  print_info "Create group: $PH_GROUP"
  kc_group_create PH_GROUP $KC_REALM $PH_GROUP ${DIR}/group-${PH_GROUP}.json
  if [ "$PRIMEHUB_MODE" == "deploy" ]; then
    print_info "Enable deployment by default at deploy mode"
    kc_group_update $KC_REALM $PH_GROUP_ID 'attributes.enabled-deployment=["true"]'
  fi

  # Group mapping
  print_info "Add group: $PH_USER -> $PH_GROUP"
  kc_user_group_add $KC_REALM $PH_USER $PH_GROUP
  kc_user_become_group_admin $KC_REALM $PH_USER $PH_GROUP

  # Add client role: 'realm-management:realm-admin' to user
  print_info "Add client role: realm-management:realm-admin -> $PH_USER"
  kc_user_add_client_role $KC_REALM $PH_USER realm-management realm-admin

  instances="$(cat /instancetypes/list.txt)"
  for instance in $instances; do
    kc_role_create ROLE_IT $KC_REALM "it:${instance}"
    print_info "Bind instancetypes: it:${instance} -> everyone"
    kc_group_add_realm_role $KC_REALM everyone "it:${instance}" || true
  done
  print_info "Add InstanceTypes: ${instances}"
  kubectl apply -n $PRIMEHUB_NAMESPACE -f /instancetypes/crds.yaml || true

  images='base-notebook pytorch-1 tf-1 tf-2'
  for image in $images; do
    kc_role_create ROLE_IMG $KC_REALM "img:${image}"
    print_info "Bind images: img:${image} -> everyone"
    kc_group_add_realm_role $KC_REALM everyone "img:${image}" || true
  done

  # add crds
  print_info "Add CRDs: img:base-notebook img:pytorch-1 img:tf-1 img:tf-2"
  kubectl apply -n $PRIMEHUB_NAMESPACE -f $DIR/crds.yaml || true
}

function add_admission_labels() {
  print_section "Add labels for admission webhook..."
  print_info "[label] 'admission-webhook=enabled' on $PRIMEHUB_NAMESPACE namesapce"
  kubectl label ns $PRIMEHUB_NAMESPACE --overwrite primehub.io/admission-webhook=enabled
}

function restart_hub() {
  print_section "Restart hub..."
  kubectl -n $PRIMEHUB_NAMESPACE delete pod -l app=jupyterhub,component=hub
}

function main() {
  prepare
  wait_for_keycloak
  kc_login
  update
  create_default_resources
  add_admission_labels
  restart_hub
  echo ""
  echo "Complete"
}

main "$@"
