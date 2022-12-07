#!/bin/bash
set -e
PRIMEHUB_ROOT=$(dirname "${BASH_SOURCE[0]}")/..
cd $PRIMEHUB_ROOT

CLUSTER_NAME=${CLUSTER_NAME:-primehub}
K8S_VERSION=${K8S_VERSION:-"v1.21.2-k3s1"}
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
k3d version list

# Create k3d
# https://github.com/rancher/k3d/issues/206
mkdir -p /tmp/k3d/kubelet/pods
k3d cluster create ${CLUSTER_NAME} -v /tmp/k3d/kubelet/pods:/var/lib/kubelet/pods:shared --image rancher/k3s:${K8S_VERSION} --k3s-server-arg '--disable=traefik' --k3s-server-arg  '--disable=servicelb' --k3s-server-arg '--disable-network-policy' --wait --kubeconfig-update-default
kubectl config view

echo "waiting for nodes ready"
until kubectl get nodes | grep ' Ready'
do
  sleep 2
done

# Helm
echo "show helm version"
helm version

# Wait for metrics api to be available
kubectl --namespace=kube-system wait --for=condition=Available --timeout=5m apiservices/v1beta1.metrics.k8s.io

# nginx
echo "init nginx-ingress"
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install nginx-ingress ingress-nginx/ingress-nginx \
    --create-namespace \
    --namespace nginx-ingress \
    --version=3.15.2 \
    --set controller.hostNetwork=true \
    --set controller.admissionWebhooks.enabled=false \
    --set controller.updateStrategy.type=RollingUpdate \
    --set controller.updateStrategy.rollingUpdate.maxUnavailable=1 \
    --set controller.updateStrategy.rollingUpdate.maxSurge=1 \
    --set defaultBackend.enabled=true

kubectl apply -f k3d/nginx-config.yaml

(
  kubectl -n nginx-ingress rollout status deploy/nginx-ingress-ingress-nginx-controller &&
  kubectl -n nginx-ingress rollout status deploy/nginx-ingress-ingress-nginx-defaultbackend &&
  kubectl port-forward -n nginx-ingress svc/nginx-ingress-ingress-nginx-controller ${PRIMEHUB_PORT}:80 --address ${BIND_ADDRESS} > /dev/null 2>&1
)&

# Label nodes
kubectl label --all --overwrite node component=singleuser-server
