#!/bin/bash
set -e
PRIMEHUB_ROOT=$(dirname "${BASH_SOURCE[0]}")/..
cd $PRIMEHUB_ROOT

export PRIMEHUB_MODE=${PRIMEHUB_MODE:-ce}
export PRIMEHUB_DOMAIN=hub.ci-e2e.dev.primehub.io
export PRIMEHUB_PASSWORD=${PH_PASSWORD}
export PRIMEHUB_PORT=${PRIMEHUB_PORT:-8080}
export KEYCLOAK_PASSWORD=$(openssl rand -hex 16)
export STORAGE_CLASS=local-path
export GRAPHQL_SECRET_KEY=$(openssl rand -hex 32)
export HUB_AUTH_STATE_CRYPTO_KEY=$(openssl rand -hex 32)
export HUB_PROXY_SECRET_TOKEN=$(openssl rand -hex 32)
export HUB_COOKIE_SECRET=$(openssl rand -hex 32)

echo "install primehub chart"
cat <<EOF > primehub-values.yaml
primehub:
  domain: ${PRIMEHUB_DOMAIN}
  port: ${PRIMEHUB_PORT}
keycloak:
  password: ${KEYCLOAK_PASSWORD}
bootstrap:
  password: ${PRIMEHUB_PASSWORD}
graphql:
  sharedGraphqlSecret: ${GRAPHQL_SECRET_KEY}
groupvolume:
  storageClass: ${STORAGE_CLASS}
ingress:
  annotations:
    kubernetes.io/ingress.allow-http: "true"
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
  hosts:
  - ${PRIMEHUB_DOMAIN}
jupyterhub:
  hub:
    db:
      pvc:
        storageClassName: ${STORAGE_CLASS}
    config:
      CryptKeeper:
        keys:
        - ${HUB_AUTH_STATE_CRYPTO_KEY}
    cookieSecret: ${HUB_COOKIE_SECRET}
  proxy:
    secretToken: ${HUB_PROXY_SECRET_TOKEN}
  singleuser:
    storage:
      dynamic:
        storageClass: ${STORAGE_CLASS}
adminNotebook:
  enabled: false

controller:
  image:
    tag: sc-28495-e1b97b
EOF

if [[ "${PRIMEHUB_MODE}" == "ee" ]]; then
  values_mode='--values k3d/ee-values.yaml'
elif [[ "${PRIMEHUB_MODE}" == "deploy" ]]; then
  values_mode='--values k3d/deploy-values.yaml'
fi

# install crds
kubectl apply -f ../crds/crd.yaml
kubectl apply -f ../crds/metacontroller/crd.yaml
kubectl apply -f ../crds/primehub-controller

helm upgrade \
  primehub ../chart \
  --install \
  --create-namespace \
  --namespace hub  \
  $values_mode \
  --timeout 30m \
  --values primehub-values.yaml \
  --values k3d/primehub-override.yaml \
  --set jupyterhub.primehub.spawnerStartTimeout=${SPAWNER_START_TIMEOUT}

# change requests.cpu to 0.1 to make sure shared runner can have enough resource
kubectl -n hub patch instancetype cpu-1 -p '{"spec":{"requests.cpu":0.1}}' --type merge || true
