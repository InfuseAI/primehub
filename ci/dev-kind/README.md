# dev-kind

## Prerequisites
  
1. **kind (kubernets in kind):** Please donwload [here](https://github.com/kubernetes-sigs/kind/releases)

1. All prerequisits of primehub (e.g. kubectl, helm, helmfile, jq).


1. Clone the primehub repo and sync the submodules. To sync the sub modules, please go to the primehub project root and run this command

   ```
   make setup-gitsubmodule
   ```

## Prepare Kind Cluster

1. Setup IP: We need a domain name for primehub. In dev environment, we use [nip service](https://nip.io/) to map `*.10.88.88.88.nip.io` to `10.88.88.88` and bind this ip to `lo` interface.
    
    
   For linux
   
   ```
   sudo ifconfig lo:0 inet 10.88.88.88 netmask 0xffffff00
   ```
    
   For osx
   
   ```
   sudo ifconfig lo0 inet 10.88.88.88 netmask 0xffffff00 alias
   ```


1. Prepare Environment Variable

   ```
   export CLUSTER_NAME="primehub"
   export BIND_ADDRESS=10.88.88.88
   ```

   
1. Create a kind cluster with default name `primehub`

    ```
    dev-kind/setup-kind.sh
    ```

    Here it will
    * create a kind cluster
    * patch local-storage-class (this is required for keycloak database)
    * label node with `component=singleuser-server`


1. Setup the kubeconfig

    ```
    export KUBECONFIG="$(kind get kubeconfig-path --name="primehub")"
    ```
    
1. Check the node available

    ```
    $ kubectl get nodes
    NAME                     STATUS   ROLES    AGE    VERSION
    primehub-control-plane   Ready    master   2m3s   v1.14.2
    ```

## Install Primehub

1. Prepare environment variable

   ```
   export PRIMEHUB_DOMAIN=hub.10.88.88.88.nip.io
   export PRIMEHUB_SCHEME=http
   export PRIMEHUB_PORT=8080 
   export KC_DOMAIN=id.10.88.88.88.nip.io
   export KC_SCHEME=http
   export KC_USER=keycloak
   export KC_PASSWORD=<keycloak password>
   export PH_PASSWORD=<phadmin passowrd>
   export PRIMEHUB_CONSOLE_DOCKER_USERNAME=<gitlab-docker-user>
   export PRIMEHUB_CONSOLE_DOCKER_PASSWORD=<gitlab-docker-password>
   export PRIMEHUB_STORAGE_CLASS=local-path
   ```

1. Initiate config. Install keycloak. Install primehub

    ```
    make init
    make keycloak-install
    make primehub-install
    ```
   
1. Patch the instancetype. Make the cpu resource request smaller in case of jupyter pod pending.

    ```
    kubectl -n hub patch instancetype cpu-only -p '{"spec":{"requests.cpu":0.5}}' --type merge    
    ```
    
1. Go to the jupyterhub page `http://hub.10.88.88.88.nip.io:8080` and login with (`phadmin`/`<password>`)

1. Launch a jupyter server for `phadmin`. Congratulations, we complete the installation.


## Destroy Kind Cluster

1. Run the cleanup script and unset `KUBECONFIG`

    ```
    dev-kind/clean.sh
    unset KUBECONFIG
    ```
