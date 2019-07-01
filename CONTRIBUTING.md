# Contributing to PrimeHub

Issues and PRs are welcome!

# Developer Certificate of Origin

PrimeHub DCO and signed-off-by process

The PrimeHub project use the signed-off-by language and process used by the Linux kernel, to give us a clear chain of trust for every patch received.

```
By making a contribution to this project, I certify that:

(a) The contribution was created in whole or in part by me and I have the right to submit it under the open source license indicated in the file; or

(b) The contribution is based upon previous work that, to the best of my knowledge, is covered under an appropriate open source license and I have the right under that license to submit that work with modifications, whether created in whole or in part by me, under the same open source license (unless I am permitted to submit under a different license), as indicated in the file; or

(c) The contribution was provided directly to me by some other person who certified (a), (b) or (c) and I have not modified it.

(d) I understand and agree that this project and the contribution are public and that a record of the contribution (including all personal information I submit with it, including my sign-off) is maintained indefinitely and may be redistributed consistent with this project or the open source license(s) involved.
```

## Using the Signed-Off-By Process

We have the same requirements for using the signed-off-by process as the Linux kernel. In short, you need to include a signed-off-by tag in every patch:

```
This is my commit message

Signed-off-by: Random J Developer <random@developer.example.org>
```

Git even has a -s command line option to append this automatically to your commit message:

```
$ git commit -s -m 'This is my commit message'
```

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

bootstrap will be done during post-install hook. It creates the default user and oauth client, and stores the oauth client secret for jupyterhub to use.

### access

You may now access http://primehub.10.88.88.88.xip.io:8080/ and login with the default user phuser and password rangstring
