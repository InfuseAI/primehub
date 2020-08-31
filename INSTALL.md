# Install PrimeHub

## Prepare the Value File
Prepare the value file `primehub-values.yaml` for helm installation. 

Key | Description
----|------------------------------------
`PRIMEHUB_DOMAIN` | The domain name of primehub. It can be the same as primehub's one.

Modify the environment variables below and execute the commands to generate the value file.

```
PRIMEHUB_DOMAIN=1.2.3.4.nip.io

cat <<EOF > primehub-values.yaml
primehub:
  domain: ${PRIMEHUB_DOMAIN}
ingress:
  annotations:
    kubernetes.io/ingress.allow-http: "true"
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
  hosts:
  -  ${PRIMEHUB_DOMAIN}
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
