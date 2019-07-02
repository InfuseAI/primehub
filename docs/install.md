# Install


## Prerequisite
- **Setup Kuberentes Cluster**. Please reference z2jh document to [setup a kubernetes cluster](https://zero-to-jupyterhub.readthedocs.io/en/latest/create-k8s-cluster.html)
- **Setup Helm**. Please reference z2jh document to [setup helm](https://zero-to-jupyterhub.readthedocs.io/en/latest/setup-helm.html#)
- **Ingress Controller**. If we select [nginx-ingress](https://github.com/helm/charts/tree/master/stable/nginx-ingress) as ingress controller, use the below command to install
  ```
  helm install --namespace nginx-ingress -n nginx-ingress stable/nginx-ingress
  ```
  For more information, please reference the ingress nginx [installation guide](https://kubernetes.github.io/ingress-nginx/deploy/#using-helm).

- **Domain name for PrimeHub** (e.g. primehub.example.com). The domain name should point to the external ip of ingress controller. In the below example, the external ip is `104.199.244.69`

  ```
  $ kubectl --namespace nginx-ingress get services -o wide -w
  NAME                             TYPE           CLUSTER-IP   EXTERNAL-IP   PORT(S)                      AGE   SELECTOR
  nginx-ingress-controller   LoadBalancer   10.20.4.90   104.199.244.69   80:32625/TCP,443:30809/TCP   52s   ...
  ```

  For non-production environment, we can use the domain name `primehub.104.199.244.69.xip.io` directly.

## Install/Upgrade the PrimeHub Chart

1. Add `infuseai` repository to helm
   ```console
   helm repo add infuseai https://charts.infuseai.io/
   helm repo update
   ```
1. Prepare `values.yaml` for configuration. The `values.yaml` is the overriding configuration values. [here](../examples/) are some examples of the value file. We recommend to download [config-basic.yaml](../examples/config-basic.yaml) as base file to configure

1. In this file, replace the `primehub.example.com` by your domain name mentioned above.

1. Generate random string for the following settings
    - `jupyterhub.auth.state.crptoKey`
    - `jupyterhub.proxy.secretToken`

    ```
    openssl rand -hex 32
    ```

1. Change the username and password for keycloak and PrimeHub users.

1. Install the chart with the release name `primehub`:

    ```console
    helm upgrade --install primehub \
        --namespace primehub  \
        --values values.yaml  \
        infuseai/primehub
    ```

1. After few minutes, we may get message as follow. 

    ```
    NOTES:
    ===========
    PrimeHub CE
    ===========

    You may now access:

      http://primehub.104.199.244.69.xip.io

    and login with the default user phuser and password randstring
    ```
1. Congratuations! Now you can login in to PrimeHub.


> If upgrade failed with this message
> ```
> Error: UPGRADE FAILED: jobs.batch "primehub-bootstrap" already exists
> ```
> please delete the job `primehub-boostrap` and upgrade again.
> 
> ```
> kubectl -n primehub delete jobs primehub-boostrap
> ```

## Configuration
The following table lists the configurable parameters of the PrimeHub chart and their default values.

Parameter | Description | Default
--- | --- | ---
`primehub.deployKeycloak` | If keycloak is installed | `true`
`primehub.keycloak.realm`  | The keycloak realm for primehub |  `primehub`
`primehub.keycloak.client` | The client name for jupyterhub |  `jupyterhub`
`primehub.keycloak.clientAdmin` | The client name for creating keycloak client |  `primehub`
`primehub.user` | The default user |  `phuser`
`primehub.password` | The password for default user |  `randstring`
`primehub.bootstrap.image.repository` | The image repository for bootstrap |  `gcr.io/google-containers/hyperkube-amd64`
`primehub.bootstrap.image.tag` | The image tag for bootstrap |  `v1.14.0`
`jupyterhub.*` | The configuration of z2jh subchart. Please reference the [z2jh](https://z2jh.jupyter.org/en/latest/reference.html#helm-chart-configuration-reference) document. |  
`keycloak.*` | The configuration of z2jh subchart. Please reference the [keycloak](https://github.com/helm/charts/tree/master/stable/keycloak#configuration) document. |  

# Uninstall the PrimeHub Chart

To uninstall/delete the `primehub`

```console
helm delete primehub --purge
```

We recommend to delete the whole namespace before reinstalling the PrimeHub, in case that there are some old settings left over.

# Administration

## Add Users

There are two way to add users. 

### From Web UI
1. login to keycloak `http://<primehub>/auth/admin/`. The user name and password are configured by `keycloak.keycloak.username` and `keycloak.keycloak.passsword`.
2. Select [Users] in the side menu
3. Click [Add user] button to create a user
4. Click the new created user
5. Select [Credentials] to change the password

### From CLI
1. Prepare the alias to keycloak admin cli `kcadm`
   ```
   alias kcadm='kubectl -n primehub exec -it primehub-keycloak-0 -- keycloak/bin/kcadm.sh'   
   ```
2. Login to keycloak admin cli. The user name and password are configured by `keycloak.keycloak.username` and `keycloak.keycloak.passsword`.
   ```   
   kcadm config credentials \
       --server http://localhost:8080/auth \
       --realm master \
       --user <admin username> \
       --password <admin password>
   ```
3. Create a user
   ```  
   kcadm create users -r primehub -s username=<user> -s enabled=true -s emailVerified=true
   ```
4. Change the password
   ```
   kcadm set-password  -r primehub --username <user> --new-password=<password>
   ```

## Configure Jupyter Profiles

Profile is the specification the jupyter server to launch. For more infomration, please reference 
[z2jh](https://z2jh.jupyter.org/en/latest/reference.html#singleuser-profilelist) document.

docker stacks provide a list of [ready-to-use notebook images](https://hub.docker.com/u/jupyter). Here is an example add an additional `datascience-notebook` to the profile list. Please store it as `profiles.yaml`

```
jupyterhub:
  singleuser:
    profileList:
      - display_name: "Shared, CPU node"
        description: "cpu node"
        kubespawner_override:
          singleuser_image_spec: jupyter/minimal-notebook
      - display_name: "Data Science"
        description: "Data Science notebook from docker stacks"
        kubespawner_override:
          singleuser_image_spec: jupyter/datascience-notebook
```          


Add one `profiles.yaml` to the helm upgrade command. 

```
helm upgrade --install primehub \
  --namespace primehub \
  --values values.yaml \
  --values profiles.yaml \
  infuseai/primehub
```
