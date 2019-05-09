# Contributing to PrimeHub

Issues and PRs are welcome!

# Setting up development environment

Since jupyterhub and keycloak needs to talk to each other with domain name, we'll use xip.io domain for local development.

A domain reachable both from your local environment and within the cluster is required.

## Kind

We recommend using [kind](https://github.com/kubernetes-sigs/kind/) for development.

Setup a alias IP on loopback interface, which can be reached from the kubernetes cluster:

on Mac:
```
sudo ifconfig lo0 inet 10.88.88.88 netmask 0xffffff00 alias
```

on Linux:
```
sudo ifconfig lo:0 inet 10.88.88.88 netmask 0xffffff00
```

Create a cluster with kind and configure kubectl:

```
kind create cluster --name primehub
export KUBECONFIG="$(kind get kubeconfig-path --name="primehub")"
```

Install helm:

```
kubectl --namespace kube-system create sa tiller
kubectl create clusterrolebinding tiller \
       --clusterrole cluster-admin \
       --serviceaccount=kube-system:tiller
helm init --service-account tiller --wait --upgrade
```

Install nginx ingress:

```
helm install --namespace nginx-ingress -n nginx-ingress stable/nginx-ingress --set controller.hostNetwork=true
```

Install local provisioner and [make it default](https://kubernetes.io/docs/tasks/administer-cluster/change-default-storage-class/):

```
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.beta.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

We'll use port 8080, hence *.10.88.88.88.xip.io:8080 to access all services. Enable this through port-forward for the nginx controller:

```
kubectl port-forward -n nginx-ingress svc/nginx-ingress-controller 8080:80 --address 10.88.88.88 &
```

## Installing PrimeHub

do this in the helm/ directory

### Add helm repos and download dependency charts

```
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/

helm dependency update primehub
```

### Install the chart

```
helm upgrade --install --namespace primehub primehub primehub --values config-kind.yaml --set-file jupyterhub.hub.extraConfig.primehub=./primehub/jupyterhub_primehub.py
```

Note that this creates a non-persistent deployment.  Due to the way keycloak chart is designed, upgrading again will destroy the in-memory database and lose all credentials.


To provide persistent (with default storage class):

```
helm upgrade --install --namespace primehub primehub primehub --values config-kind.yaml --values config-persist.yaml --set-file jupyterhub.hub.extraConfig.primehub=./primehub/jupyterhub_primehub.py
```

Note that there's a warning due to the default value of jupyterhub chart.  This can be ignored:

```
Warning: Merging destination map for chart 'jupyterhub'. Cannot overwrite table item 'extraEnv', with non table value: map[]
```

This should finish within a few minutes. Note that hub won't start until `primehub-secret` created in the bootstrap process.

### bootstrap

bootstrap will be done with helm-chart's post-install hook. It will run the following commands:

```
export DOMAIN=10.88.88.88.xip.io:8080
kubectl exec -ti -n primehub primehub-keycloak-0 -- keycloak/bin/kcadm.sh  config credentials --server http://localhost:8080/auth  --realm master --user keycloak --password CHANGEKEYCLOAKPASSWORD
kubectl exec -ti -n primehub primehub-keycloak-0 -- keycloak/bin/kcadm.sh  create realms -s realm=primehub -s enabled=true
client_id=$(kubectl exec -ti -n primehub primehub-keycloak-0 -- keycloak/bin/kcadm.sh  create clients -r primehub -s clientId=jupyterhub -s "redirectUris+=http://hub.${DOMAIN}/*" -f - --id < ./primehub/keycloak/client-jupyterhub.json)

kubectl exec -ti -n primehub primehub-keycloak-0 -- keycloak/bin/kcadm.sh  create users -r primehub -s username=phuser -s enabled=true -s emailVerified=true
kubectl exec -ti -n primehub primehub-keycloak-0 -- keycloak/bin/kcadm.sh  set-password  -r primehub --username phuser --new-password=randstring

client_secret=$(kubectl exec -ti -n primehub primehub-keycloak-0 -- keycloak/bin/kcadm.sh get clients/$client_id/client-secret -r primehub  | jq -r .value)

kubectl create -n primehub secret generic primehub-secret --from-literal=keycloak.url=http://id.${DOMAIN} --from-literal=keycloak.clientSecret=$client_secret

# for testing, set realm sslRequired=none
# also set the user to admin in keycloak
# export KCADM="kubectl exec -ti -n primehub primehub-keycloak-0 -- keycloak/bin/kcadm.sh"
# $KCADM add-roles -r primehub --uusername phuser --cclientid realm-management --rolename realm-admin

echo Hub: hub.${DOMAIN}
echo keycloak: id.${DOMAIN}/auth/admin/primehub/console
```

### access

You may now access http://hub.10.88.88.88.xip.io:8080/ and login with the default user phuser and password rangstring
