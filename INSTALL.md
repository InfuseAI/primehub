# Install PrimeHub

## Prepare the Value File
Prepare the value file `primehub-values.yaml` for helm installation. 

Key | Description
----|------------------------------------
`PRIMEHUB_DOMAIN` | The domain name of primehub. It can be the same as primehub's one.
`PRIMEHUB_PASSWORD` | The password for primehub admin. (The default username of admin is `phadmin`)
`KEYCLOAK_PASSWORD` | The master password of keycloak
`STORAGE_CLASS` | The storage class for persistence storage
`GRAPHQL_SECRET_KEY` | The graphql API secret key
`HUB_AUTH_STATE_CRYPTO_KEY` | The jupyterhub crypo key. Please reference the [z2jh document](https://zero-to-jupyterhub.readthedocs.io/en/latest/reference/reference.html#auth-state-cryptokey).
`HUB_PROXY_SECRET_TOKEN` | The jupyterhub secret. Please reference the [z2jh document](https://zero-to-jupyterhub.readthedocs.io/en/latest/reference/reference.html#proxy-secrettoken).

Modify the environment variables below and execute the commands to generate the value file.

```
PRIMEHUB_DOMAIN=1.2.3.4.nip.io
PRIMEHUB_PASSWORD=__my_password__
KEYCLOAK_PASSWORD=__my_password__
STORAGE_CLASS=__storage_class__
GRAPHQL_SECRET_KEY=$(openssl rand -hex 32)
HUB_AUTH_STATE_CRYPTO_KEY=$(openssl rand -hex 32)
HUB_PROXY_SECRET_TOKEN=$(openssl rand -hex 32)

cat <<EOF > primehub-values.yaml
primehub:
  domain: ${PRIMEHUB_DOMAIN}
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
  -  ${PRIMEHUB_DOMAIN}
jupyterhub:
  auth:
    state:
      cryptoKey: ${GRAPHQL_SECRET_KEY}
  hub:
    db:
      pvc:
        storageClassName: ${STORAGE_CLASS}
  proxy:
    secretToken: ${HUB_PROXY_SECRET_TOKEN}
  singleuser:
    storage:
      dynamic:
        storageClass: ${STORAGE_CLASS}
EOF
```

## Add the chart repository

```
helm repo add infuseai https://charts.infuseai.io
helm repo update
```

## Install

1. Run helm command to install primehub

   ```
   helm upgrade \
     primehub infuseai/primehub \
     --install \
     --create-namespace \
     --namespace hub  \
     --values primehub-values.yaml
   ```

   > In the first time installation, it may take a longer time to pull images. You can add `--timeout 30m` to change the default timeout duration.

2. Label the nodes which can be assigned for jupyterhub servers

   ```
   kubectl label node component=singleuser-server --all
   ```
## Verify the Installation

1. Run this command to wait for PrimeHub ready

   ```
   kubectl -n hub rollout status deploy/primehub-console
   ```

2. Open `http://${PRIMEHUB_DOMAIN}` and log in by the admin username and password.

3. Open *Jupyterhub* icon

4. Click the *Start notebook* button to launch a Jupyter instance
