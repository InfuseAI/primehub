#!/bin/bash

SCRIPTS_ROOT=$(dirname "${BASH_SOURCE[0]}"); source $SCRIPTS_ROOT/common.sh

CHART_ROOT=$(dirname "${BASH_SOURCE[0]}")/../helm

pushd $CHART_ROOT

helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
helm dependency update primehub

# by default we install primehub without persistence

helm upgrade --install --namespace primehub primehub primehub --values ../config-kind.yaml --set-file jupyterhub.hub.extraConfig.primehub=./primehub/jupyterhub_primehub.py

# for persist
# helm upgrade --install --namespace primehub primehub primehub --values ../config-kind.yaml --values ../config-persist.yaml --set-file jupyterhub.hub.extraConfig.primehub=./primehub/jupyterhub_primehub.py

popd
