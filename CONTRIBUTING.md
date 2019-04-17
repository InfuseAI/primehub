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

## install tools

There are helper scripts in `scripts/` path. You can finish primehub-ce installation following this sequences:

```
./00-setup.sh
./01-helm-release.sh
./02-keycloak.sh
```

### ./00-setup.sh

  * install helm tiller to kind cluster
  * install nginx ingress: it routes \*.10.88.88.88.xip.io:8080 to our services
  * configure kubernetes dynamic storage provisioner

There are two endpoints connected from web browser:

  * http://id.10.88.88.88.xip.io:8080 
  * http://hub.10.88.88.88.xip.io:8080 

We need to setup port-forward by the instruction:

```
kubectl port-forward -n nginx-ingress svc/nginx-ingress-controller 8080:80 --address 10.88.88.88 &
```

### ./01-helm-release.sh

  * update add helm repo and update dependency
    * [Keycloak](https://www.keycloak.org/): Keycloak is an open source identity and access management solution.
    * [JupyterHub](https://jupyterhub.readthedocs.io/en/stable/): a multi-user Hub, spawns, manages, and proxies multiple instances of the single-user Jupyter notebook server.
  * install PrimeHub

### ./02-keycloak.sh

  * create realm
  * create Keycloak client and configure it
  * create a user account
  * save credentials in the kubernets' secret

## Cautions

### Persistence

By default we install primehub without a persistence disk with the following command:

```
helm upgrade --install --namespace primehub primehub primehub --values config-kind.yaml --set-file jupyterhub.hub.extraConfig.primehub=./primehub/jupyterhub_primehub.py
```

Note that this creates a non-persistent deployment.  Due to the way keycloak chart is designed, upgrading again will destroy the in-memory database and lose all credentials.


To provide persistent (with default storage class):

```
helm upgrade --install --namespace primehub primehub primehub --values config-kind.yaml --values config-persist.yaml --set-file jupyterhub.hub.extraConfig.primehub=./primehub/jupyterhub_primehub.py
```

### warning from JupyterHub

Note that there's a warning due to the default value of jupyterhub chart.  This can be ignored:

```
Warning: Merging destination map for chart 'jupyterhub'. Cannot overwrite table item 'extraEnv', with non table value: map[]
```

This should finish within a few minutes. Note that hub won't start until `primehub-secret`, please follow the bootstrap instructions.


## The road to PrimeHub

After installation finished, you may now access PrimeHub:

* url: http://hub.10.88.88.88.xip.io:8080/
* username: phuser
* password: randstring
