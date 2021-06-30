HELM_VERSION=v3.3.4
HELMFILE_VERSION=v0.125.0

PROMETHEUS_CHART_VERSION="8.9.3"
PRIMEHUB_GRAFANA_DASHBOARD_BASIC_CHART_VERSION="1.0.0"
NVIDIA_GPU_EXPORTER_VERSION="0.4.0"

function info() {
  echo -e "\033[0;32m$1\033[0m"
}

function warn() {
  echo -e "\033[0;93m$1\033[0m"
}

function error() {
  echo -e "\033[0;91m$1\033[0m" >&2
}

function install::helm() {
  local platform=$(uname | tr '[:upper:]' '[:lower:]')
  info "[Install] helm"
  wget -O helm.tgz https://get.helm.sh/helm-${HELM_VERSION}-${platform}-amd64.tar.gz
  tar zxvf helm.tgz; sudo mv linux-amd64/* /usr/bin/; rm -f helm.tgz
}

function install::helmfile() {
  local platform=$(uname | tr '[:upper:]' '[:lower:]')
  info "[Install] helmfile"
  wget -O helmfile "https://github.com/roboll/helmfile/releases/download/${HELMFILE_VERSION}/helmfile_${platform}_amd64"
  chmod +x helmfile; sudo mv helmfile /usr/bin/
}

function install::chartpress() {
  info "[Install] chartpress"
  python3 -m venv .venv
  source .venv/bin/activate
  pip install --upgrade pip
  pip install -r requirements.txt
}

function install::submodule() {
  info "[Install] git submodule"
  git submodule init
  git submodule sync
  git submodule update
}

function helm::update_dependency() {
  info "[Helm] Update dependency"
  pushd $CHART_ROOT
  # helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
  # helm dependency update
  popd
}

function helm::fetch_prometheus_operator_chart() {
  info "[Helm] Fetch Prometheus Operator"
  pushd $PROJECT_ROOT
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm fetch --untar --untardir install/charts prometheus-community/prometheus-operator --version ${PROMETHEUS_CHART_VERSION} || true
  popd
}

function helm::fetch_primehub_grafana_dashboard_basic_chart() {
  info "[Helm] Fetch PrimeHub Grafana Dashboard Basic"
  pushd $PROJECT_ROOT
  helm repo add infuseai https://charts.infuseai.io
  helm fetch --untar --untardir install/charts infuseai/primehub-grafana-dashboard-basic --version ${PRIMEHUB_GRAFANA_DASHBOARD_BASIC_CHART_VERSION} || true
  popd
}

function helm::fetch_nvidia_gpu_exporter() {
  info "[Helm] Fetch Nvidia GPU Exporter"
  pushd $PROJECT_ROOT
  helm repo add infuseai https://charts.infuseai.io
  helm fetch --untar --untardir install/charts infuseai/nvidia-gpu-exporter --version ${NVIDIA_GPU_EXPORTER_VERSION} || true
  popd
}

function helm::package() {
  local version=${1:-}
  info "[Helm] Build package ${CHART_NAME} version: ${version}"

  pushd $CHART_ROOT/..
  if [[ "${version}" != "" ]]; then
    helm package $CHART_NAME --version ${version}
  else
    helm package $CHART_NAME
  fi
  popd
}

function helm::patch_app_version() {
  info "[Patch] app version: $(git describe --tags)"
  sed -i "s/LOCAL/$(git describe --tags)/g" ${CHART_ROOT}/Chart.yaml
}

function actions::build_release_package() {
  info "[GitHub Action] Build PrimeHub Chart Release Package"
  pushd $PROJECT_ROOT/../
  local version=$(git describe --tags)
  tar czf primehub-$version.tar.gz primehub
  mv primehub-$version.tar.gz $PROJECT_ROOT
  popd
}

function ci::setup_ci_environment_and_publish() {
  info "[CI] Setup build environment"
  pushd $CHART_ROOT/..

  # Create symbolic link `primehub` for chartpress
  ln -nfs $CHART_ROOT $CHART_NAME

  # show variables
  export

  # !!! important
  # make sure we are in circle-ci, before overwrite ~/.ssh/config
  if [[ ! "$CIRCLECI" == "true" ]]; then
      echo "it can be only in ci-environment"
      exit 1
  fi

  if [ ! -f "$CI_PUBLISH_KEY" ]; then
      echo "cannot found publish-key: $CI_PUBLISH_KEY"
      exit 1
  fi

  # we have to work around the circle-ci problem
  # https://github.com/docksal/ci-agent/issues/26
  cat > ~/.ssh/config <<EOF
Host *
  IdentitiesOnly yes

Host github.com
  IdentitiesOnly no
  IdentityFile $CI_PUBLISH_KEY
EOF

  # clean up previous sessions
  ssh-add -D

  # configure publish author
  git config --global user.email "ci@infuseai.io"
  git config --global user.name "circle-ci"

  # publish chart
  if [ -z "${CIRCLE_TAG+x}" ]; then
    info "[Chartpress] Build package ${CHART_NAME} commit-tag: $CIRCLE_SHA1 "
    chartpress --commit-range $CIRCLE_SHA1 --publish-chart
  else
    info "[Chartpress] Build package ${CHART_NAME} version: $CIRCLE_TAG "
    chartpress --tag $CIRCLE_TAG --publish-chart
  fi
  popd
}
