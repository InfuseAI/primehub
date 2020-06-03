#!/bin/bash
set -e

# print all pod stats and export kind logs when job failed
cleanup() {
  echo "pods in all namespaces"
  kubectl get pod --all-namespaces
  echo "events in all namespaces"
  kubectl get events --all-namespaces
  echo "export kind logs"
  mkdir -p kind_logs
  kind export logs --name primehub kind_logs
}
trap "cleanup" ERR

# install tools

KIND_VERSION=0.7.0
HELM_VERSION=2.16.1

curl -Lo kind https://github.com/kubernetes-sigs/kind/releases/download/v${KIND_VERSION}/kind-linux-amd64 && \
  chmod +x kind && \
  mv kind /usr/local/bin/

curl -ssL https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar -xz --strip-components 1 linux-amd64/helm && \
    chmod +x helm && \
    sudo mv helm /usr/local/bin/


INFRA_UPGRADE_TEST=${INFRA_UPGRADE_TEST:-false}
EXECUTE_E2E_TEST=${EXECUTE_E2E_TEST:-false}

echo "run infra-upgrade-test: $INFRA_UPGRADE_TEST"

checkout_branch_before_ci_process() {
  echo "ci-ref: $CI_COMMIT_REF_NAME"
  if [ "$INFRA_UPGRADE_TEST" != "true" ]; then
    echo "skip infa-upgrade-test"
    return
  fi

  git fetch --tags

  if [ "$CI_COMMIT_REF_NAME" == "master" ]; then
    LATEST=$(git tag -l | grep -e "^v" | grep -v "rc" | sort -V | tail -n 1)
    PREVIOUS=$(git tag -l | grep -e "^v" | grep -v "rc" | grep -v $(echo "$LATEST" | awk -F '.' '{print $1"."$2"."}') | sort -V | tail -n 1)
  else
    # release branch
    LATEST=$(git describe --tags --abbrev=0)
    PREVIOUS=$(git tag -l | grep -e "^v" | sort -V | grep $LATEST -B99 | grep -v "rc" | grep -v $LATEST | tail -1)
  fi

  if [ "$INFRA_UPGRADE_FROM" == "latest" ]; then
    echo "checkout latest release: $LATEST"
    INFRA_UPGRADE_REF=$LATEST

  else
    # FROM=prev
    echo "checkout previous release: $PREVIOUS"
    INFRA_UPGRADE_REF=$PREVIOUS
  fi
  git checkout $INFRA_UPGRADE_REF
  git submodule init && git submodule sync && git submodule update --init --recursive && git submodule status
}

checkout_head_branch_and_upgrade() {
  if [ "$INFRA_UPGRADE_TEST" != "true" ]; then
    echo "skip infa-upgrade-test"
    return
  fi

  echo "upgrading"
  # Remove local change
  git checkout . && git clean -df

  # Checkout back to current commit
  git checkout -
  git submodule init && git submodule sync && git submodule update --init --recursive && git submodule status
  cp ci/helm_override/primehub.yaml $(bin/phenv --effective-path)/helm_override/

  # If version less than v2.0.0
  if semver_less_than "$INFRA_UPGRADE_REF" "v2.0.0"; then
    migrate_from_1_x
  fi

  make primehub-upgrade
}

migrate_from_1_x() {
  echo "migrate from primehub 1.x"

  echo "remove old legacy releases"
  helm delete primehub-prerequisite primehub-console hub admin-notebook --purge
  kubectl -n hub delete pods -l component=hub --force --grace-period=0
  while kubectl -n hub get pvc hub-db-dir >& /dev/null ; do sleep 2; done

  echo "install primehub release"
  cp ci/helm_override/primehub.yaml $(bin/phenv --effective-path)/helm_override/
  make primehub-install
}

semver_less_than() {
  if [[ $(echo -e "$1\n$2" | sort -rV | head -1) == $1 ]]; then
    return 1
  fi
}

wait_for_docker() {
  local now=$SECONDS
  local timeout=600
  while true; do
    # it might fail
    echo "checking docker"
    set +e
    docker info > /dev/null 2>&1
    ret=$?
    set -e
    if [ "$ret" == "0" ]; then
      echo "docker is available now"
      break
    fi
    if (( $SECONDS - now > $timeout )); then
      return 1
    fi
    sleep 5
  done
  return 0
}

wait_for_graphql() {
  local now=$SECONDS
  local timeout=600
  while true; do
    # it might fail
    echo "checking graphql up"
    set +e
    kubectl get pods -n hub -l app.kubernetes.io/name=primehub-graphql | grep "2/2" > /dev/null 2>&1
    ret=$?
    set -e
    if [ "$ret" == "0" ]; then
      echo "Graphql is available now"
      break
    fi
    if (( $SECONDS - now > $timeout )); then
      return 1
    fi
    sleep 5
  done
  return 0
}

wait_for_console() {
  local now=$SECONDS
  local timeout=600
  while true; do
    # it might fail
    echo "Checking console up..."
    set +e
    kubectl get pods -n hub -l app.kubernetes.io/name=primehub-console | grep "2/2" > /dev/null 2>&1
    ret=$?
    set -e
    if [ "$ret" == "0" ]; then
      echo "Console is available now"
      break
    fi
    if (( $SECONDS - now > $timeout )); then
      return 1
    fi
    sleep 5
  done
  return 0
}

# ssh
#echo "configure ssh-agent"
#eval $(ssh-agent -s)
#echo -e "$SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add - > /dev/null
#mkdir -p ~/.ssh
#chmod 700 ~/.ssh
#echo -e "$SSH_KNOWN_HOSTS" > ~/.ssh/known_hosts
#chmod 644 ~/.ssh/known_hosts
git submodule init && git submodule sync && git submodule update --init --recursive && git submodule status


# enable docker in docker
echo "start docker in docker"
/start.sh &

export CLUSTER_NAME="primehub"
export BIND_ADDRESS=10.88.88.88
export PRIMEHUB_SCHEME="http"
export PRIMEHUB_DOMAIN="hub.ci-e2e.dev.primehub.io"
export PRIMEHUB_PORT=$(( $RANDOM % 50000 + 10000 ))
export KC_SCHEME="http"
export KC_DOMAIN="id.ci-e2e.dev.primehub.io"
export KC_PORT=${PRIMEHUB_PORT}
export PH_USERNAME="phadmin"
export PH_PASSWORD=$(openssl rand -hex 16)
export PRIMEHUB_STORAGE_CLASS=local-path
export PRIMEHUB_MODE=${PRIMEHUB_MODE:-ee}

rm -f env_file
echo CLUSTER_NAME=$CLUSTER_NAME >> env_file
echo BIND_ADDRESS=$BIND_ADDRESS >> env_file
echo PRIMEHUB_SCHEME=$PRIMEHUB_SCHEME >> env_file
echo PRIMEHUB_DOMAIN=$PRIMEHUB_DOMAIN >> env_file
echo PRIMEHUB_PORT=$PRIMEHUB_PORT >> env_file
echo KC_SCHEME=$KC_SCHEME >> env_file
echo KC_DOMAIN=$KC_DOMAIN >> env_file
echo KC_PORT=$KC_PORT >> env_file
echo PH_USERNAME=$PH_USERNAME >> env_file
echo PH_PASSWORD=$PH_PASSWORD >> env_file
echo PRIMEHUB_STORAGE_CLASS=$PRIMEHUB_STORAGE_CLASS >> env_file
echo PRIMEHUB_MODE=$PRIMEHUB_MODE >> env_file

ifconfig lo:0 inet ${BIND_ADDRESS} netmask 0xffffff00

# wait for docker in docker
echo "waiting for docker"
wait_for_docker

# install cluster
echo "create a cluster"
dev-kind/setup-kind.sh

# install primehub
echo "install primehub"
checkout_branch_before_ci_process
cp ci/helm_override/* etc/helm_override/
dev-kind/install-components.sh

# upgrade
checkout_head_branch_and_upgrade

# apply dev license
DEV_LICENSE=${DEV_LICENSE:-false}
if [ "$DEV_LICENSE" != "false" ]; then
  echo "Applying License for test."
  echo "$DEV_LICENSE" | kubectl apply -n hub -f -
  kubectl -n hub get license primehub-license -oyaml
  sleep 30
  wait_for_graphql
  wait_for_console
fi

# ensure rollout before testing
kubectl get deploy -n hub -o json | jq -r '.items[] | .metadata.name' | xargs -n1 kubectl rollout status -n hub deployment

# a bit more verbose
kubectl get pod  -n hub  -o=custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,MEMLIMITS:.spec.containers[*].resources.limits.memory,MEMREQUESTS:.spec.containers[*].resources.requests.memory,CPULIMITS:.spec.containers[*].resources.limits.cpu,CPUQUESTS:.spec.containers[*].resources.requests.cpu,STATUS:.status.phase'

# somehow the old rs of graphql server is very slow to get rid of
kubectl describe deploy -n hub primehub-graphql
sleep 60
kubectl describe deploy -n hub primehub-graphql
kubectl get pod  -n hub  -o=custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,MEMLIMITS:.spec.containers[*].resources.limits.memory,MEMREQUESTS:.spec.containers[*].resources.requests.memory,CPULIMITS:.spec.containers[*].resources.limits.cpu,CPUQUESTS:.spec.containers[*].resources.requests.cpu,STATUS:.status.phase'

# test
for filename in tests/*.sh; do echo $filename; bin/phenv $filename; done

# e2e test
if [ "$EXECUTE_E2E_TEST" == "true" ]; then
  source /root/.bashrc
  mkdir -p e2e/screenshots e2e/webpages
  /node_modules/cucumber/bin/cucumber-js tests/features/ -f json:tests/report/cucumber_report.json --tags "@released and not @wip"
fi
