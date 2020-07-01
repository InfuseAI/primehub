#!/bin/bash
set -e
PRIMEHUB_ROOT=$(dirname "${BASH_SOURCE[0]}")/..
cd $PRIMEHUB_ROOT

CLUSTER_NAME=${CLUSTER_NAME:-primehub}
K8S_VERSION=${K8S_VERSION:-"v1.17.7-k3s1"}
BIND_ADDRESS=${BIND_ADDRESS:-10.88.88.88}
PRIMEHUB_PORT=${PRIMEHUB_PORT:-8080}

if [ ! command -v k3d &> /dev/null ]; then
  echo "please install k3d: https://k3d.io/"
  exit 1
fi

if [ ! command -v kubectl &> /dev/null ]; then
  echo "please install kubectl"
  exit 1
fi

if [ ! command -v helm &> /dev/null ]; then
  echo "please install helm"
  exit 1
fi

k3d version

# Create k3d
k3d create --name ${CLUSTER_NAME} --image=rancher/k3s:${K8S_VERSION} --server-arg '--no-deploy=traefik' --wait 120
mkdir -p ~/.kube
cp $(k3d get-kubeconfig --name=${CLUSTER_NAME}) ~/.kube/config

echo "waiting for nodes ready"
until kubectl get nodes | grep ' Ready'
do
  sleep 2
done

# Helm
echo "init helm"
kubectl apply -f k3d/helm-rbac.yml
helm init --service-account tiller --wait
helm version
echo "end helm"

# nginx
echo "init nginx-ingress"
helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm upgrade --install --namespace nginx-ingress nginx-ingress stable/nginx-ingress --version=1.31.0 --set controller.hostNetwork=true
kubectl apply -f k3d/nginx-config.yaml

(
  kubectl -n nginx-ingress rollout status deploy/nginx-ingress-controller &&
  kubectl -n nginx-ingress rollout status deploy/nginx-ingress-default-backend &&
  kubectl port-forward -n nginx-ingress svc/nginx-ingress-controller ${PRIMEHUB_PORT}:80 --address ${BIND_ADDRESS} > /dev/null 2>&1
)&

# Label nodes
kubectl label --all --overwrite node component=singleuser-server
