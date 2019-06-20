function install::helm() {
  wget -O helm.tgz https://storage.googleapis.com/kubernetes-helm/helm-v2.13.1-linux-amd64.tar.gz
  tar zxvf helm.tgz; sudo mv linux-amd64/* /usr/bin/; rm -f helm.tgz
  helm init --client-only
}

function install::chartpress() {
  python3 -m venv .venv
  source .venv/bin/activate
  pip install --upgrade pip
  pip install -r requirements.txt
}

function helm::update_dependency() {
  pushd $CHART_ROOT
  helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
  helm repo add keycloak https://kubernetes-charts.storage.googleapis.com/
  helm dependency update
  popd
}

function helm::package() {
  pushd $CHART_ROOT/..
  helm package $CHART_NAME
  popd
}

function ci::setup_inject_values() {
  python ${PROJECT_ROOT}/ci/update-values.py ${PROJECT_ROOT}/helm/primehub/values.yaml ${PROJECT_ROOT}/helm/primehub/jupyterhub_primehub.py
}

function ci::setup_ci_environment_and_publish() {
  pushd $CHART_ROOT/..

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
  chartpress --commit-range $CIRCLE_SHA1 --publish-chart

  popd
}
