
# Getting Started

Here we will install a primehub in a local machine. We recommend using [kind](https://github.com/kubernetes-sigs/kind/) for kubernetes in local.

Since jupyterhub and keycloak needs to talk to each other with domain name, we'll use `xip.io` domain for local deployment. A domain reachable both from your local environment and within the cluster is required.

## Install Local Kubernetes Cluster

1. Create a cluster with kind and configure `KUBECONFIG`

   ```console
   kind create cluster --name primehub
   export KUBECONFIG="$(kind get kubeconfig-path --name="primehub")"
   ```

1. Setup helm

   ```console
   kubectl --namespace kube-system create sa tiller
   kubectl create clusterrolebinding tiller \
         --clusterrole cluster-admin \
         --serviceaccount=kube-system:tiller
   helm init --service-account tiller --wait --upgrade
   ```

1. Install nginx ingress:

   ```console
   helm install --namespace nginx-ingress -n nginx-ingress stable/nginx-ingress --set controller.hostNetwork=true
   ```

   Wait for nginx ingress ready

   ```console
   kubectl --namespace nginx-ingress rollout status deploy/nginx-ingress-default-backend
   ```

1. Setup a alias IP on loopback interface, which can be reached from the kubernetes cluster:

   on Mac:
   
   ```console
   sudo ifconfig lo0 inet 10.88.88.88 netmask 0xffffff00 alias
   ```

   on Linux:
   
   ```console
   sudo ifconfig lo:0 inet 10.88.88.88 netmask 0xffffff00
   ```

1. We'll use port 8080, hence *.10.88.88.88.xip.io:8080 to access all services. Enable this through port-forward for the nginx controller:

   ```console
   kubectl port-forward \
       --namespace nginx-ingress \
       --address 10.88.88.88 \
       svc/nginx-ingress-controller 8080:80  &
   ```

1. Make sure port forward working
   
   ```console
   curl http://xyz.10.88.88.88.xip.io:8080/                                                                                           
   ```

   In normal case, it will return this message

   ```console
   default backend - 404
   ```
 

1. Install `local path provisioner` and [make it default](https://kubernetes.io/docs/tasks/administer-cluster/change-default-storage-class/):

   ```console
   kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
   kubectl annotate storageclass standard storageclass.beta.kubernetes.io/is-default-class=false --overwrite
   kubectl annotate storageclass local-path storageclass.beta.kubernetes.io/is-default-class=true --overwrite
   ```


# Install PrimeHub
1. Add helm repos and download dependency charts

   ```console
   helm repo add infuseai https://charts.infuseai.io/
   ```

1. Prepare customization value file. Please download the `config-kind.yaml` from [here](../examples/config-kind.yaml)
   
1. Install the chart

   ```
   helm upgrade --install primehub \
     --namespace primehub \
     --values config-kind.yaml \
     infuseai/primehub
   ```

   > *\* Note that there's a warning due to the default value of jupyterhub chart [jupyterhub/zero-to-jupyterhub-k8s #653](https://github.com/jupyterhub/zero-to-jupyterhub-k8s/issues/653).  This can be ignored:*
   >
   > ```
   > 2019/06/20 18:49:49 warning: cannot overwrite table with non table for extraEnv (map[])
   > 2019/06/20 18:49:49 warning: cannot overwrite table with non table for extraEnv (map[])
   > 2019/06/20 18:49:49 warning: cannot overwrite table with non table for extraEnv (map[])
   > 2019/06/20 18:49:49 warning: cannot overwrite table with non table for extraEnv (map[])
   > ```
   
   > *\* If you encounter the below message, it could be because the pod is still pulling an image.*
   > ```
   > Error: timed out waiting for the condition
   > ```
   > 
   > *Please delete the primehub release and install again.*
   > ```
   > helm delete primehub --purge
   > ```

1. You may now access http://primehub.10.88.88.88.xip.io:8080/
1. login with the default user `phuser` and password `randstring`.


# Destroy the Cluster

Destroy the kind cluster by this command

```
kind delete cluster --name primehub
```
