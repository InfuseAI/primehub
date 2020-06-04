#!/bin/bash
set -e
PRIMEHUB_ROOT=$(dirname "${BASH_SOURCE[0]}")/..
cd $PRIMEHUB_ROOT

CLUSTER_NAME=${CLUSTER_NAME:-primehub}
K8S_VERSION=${K8S_VERSION:-"v1.17.5"}
BIND_ADDRESS=${BIND_ADDRESS:-10.88.88.88}
PRIMEHUB_PORT=${PRIMEHUB_PORT:-8080}

if [ ! command -v kind &> /dev/null ]; then
  echo "please install kind: https://kind.sigs.k8s.io/"
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

kind version

# Create KIND
kind create cluster --name ${CLUSTER_NAME} --image=kindest/node:${K8S_VERSION}
kubectl get nodes

echo "wait for nodes ready"
kubectl wait --timeout=2m --for=condition=Ready nodes --all
kubectl get nodes

# RBAC. Cluster Admin
kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default || true

# local storage
echo
echo "configure local-path-storage for applications that use hostPath to save data (eg. keycloak in our case)"
echo "see as https://github.com/kubernetes-sigs/kind/issues/118#issuecomment-475134086"
echo
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# DNS, make 8.8.8.8 the upstream DNS
kubectl apply -f dev-kind/coredns-config.yaml
if [ "$K8S_VERSION" == "v1.15.7" ]; then
  kubectl apply -f dev-kind/coredns-config-1.15.yaml
fi

# Helm
echo "init helm"
kubectl apply -f dev-kind/helm-rbac.yml
helm init --service-account tiller --wait
helm version
echo "end helm"

# nginx
echo "init nginx-ingress"
helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm upgrade --install --namespace nginx-ingress nginx-ingress stable/nginx-ingress --version=1.31.0 --set controller.hostNetwork=true
kubectl apply -f dev-kind/nginx-config.yaml

(
  kubectl -n nginx-ingress rollout status deploy/nginx-ingress-controller &&
  kubectl -n nginx-ingress rollout status deploy/nginx-ingress-default-backend &&
  kubectl port-forward -n nginx-ingress svc/nginx-ingress-controller ${PRIMEHUB_PORT}:80 --address ${BIND_ADDRESS} > /dev/null 2>&1
)&


# Label nodes
kubectl label --all --overwrite node component=singleuser-server
