# PrimeHub Chart

# Configuration

## Common Settings
Parameter | Description | Default
--- | --- | ---
`primehub.scheme` | The url scheme for primehub |  `http`
`primehub.domain` | The url domain for primehub. Cannot be a ip address. | *required*
`primehub.port` | The url port for primehub  | no port in url
`primehub.keycloak.scheme` | The url scheme for keycloak | `http`
`primehub.keycloak.domain` | The url domain for keycloak. Cannot be a ip address.| *required*
`primehub.keycloak.port` | The url port for keycloak | no port in url
`primehub.keycloak.username` | The master username for keycloak master realm | `keycloak`
`primehub.keycloak.password` | The master password for keycloak master realm | *required*
`primehub.keycloak.maxFreeSockets` | Maximum number of sockets (per host) to leave open in a free state | `10`
`primehub.keycloak.maxSockets` | Maximum number of sockets to allow per host | `80`
`primehub.keycloak.realm` | The keycloak realm for primehub | `primehub`
`primehub.keycloak.clientId` | The keycloak client id for primehub | `admin-ui`
`primehub.keycloak.rolePrefix` | The prefix of roles for the resource-group binding | `""`
`primehub.sharedVolumeStorageClass` | The storage class for shared volume. If the value is empty string `""`, it means to use `groupvolume` to provision shared volume | `""`

## Ingress
Parameter | Description | Default
--- | --- | ---
`ingress.annotations` | Annotations for ingress| `{}`
`ingress.hosts` | a list of ingress hosts | `[]`
`ingress.tls` | 	a list of ingress tls items | `[]`

## Primehub Console
Parameter | Description | Default
--- | --- | ---
`console.locale` | The language of console | `en`
`console.readOnlyOnInstanceTypeAndImage` | Whether we only allow read operations and group-assignment on instanceType/image form | `false`
`console.replicas` | The number of primehub console replicas| `1`
`console.image.repository` | The primehub console image repository | `infuseai/primehub-console`
`console.image.tag` | The primehub console image tag | Please see [values.yaml](values.yaml)
`console.image.pullPolicy` | The primehub console image pull policy | `IfNotPresent`
`console.image.credentials.*` | The credential for primehub console image | `null`
`console.resources` | Pod resource requests and limits | Please see [values.yaml](values.yaml)
`console.nodeSelector` | Node labels for pod assignment | `{}`
`console.affinity` | Pod affinitiy |  `[]`
`console.tolerations` | Node taints to tolerate| `{}`

## Graphql Server
Parameter | Description | Default
--- | --- | ---
`graphql.sharedGraphqlSecret` | Secret key to request read-only graphql with. Client should put this shared key in header Authorization: `Bearer <SHARED_GRAPHQL_SECRET_KEY>` | *required*
`graphql.playgroundEnabled` | Enable the graphql playground | `false`
`graphql.apolloTracing` | Enable appolo tracing | `false`
`graphql.defaultUserVolumeCapacity` | Default user volume capacity | `20G`
`graphql.replicas` | The number of graphql server replicas | `1`
`graphql.image.repository` | The graphql server image repository | `infuseai/primehub-console-graphql`
`graphql.image.tag` | The graphql server image tag | Please see [values.yaml](values.yaml)
`graphql.image.pullPolicy` | The graphql server image pull policy | `IfNotPresent`
`graphql.image.credentials.*` | The credential for graphql server image | `null`
`graphql.resources` | Pod resource requests and limits | Please see [values.yaml](values.yaml)
`graphql.nodeSelector` | Node labels for pod assignment | `{}`
`graphql.affinity` | Pod affinitiy | `[]`
`graphql.tolerations` | Node taints to tolerate| `{}`

## Watcher
Parameter | Description | Default
--- | --- | ---
`watcher.replicas` | The number of watcher replicas | `1`
`watcher.image.credentials.*` | The credential for watcher image | `null`
`watcher.image.repository` | The watcher image repository | `infuseai/primehub-console-watcher`
`watcher.image.tag` | The watcher image tag | Please see [values.yaml](values.yaml)
`watcher.image.pullPolicy` | The watcher image pull policy | `IfNotPresent`
`watcher.resources` | Pod resource requests and limits | Please see [values.yaml](values.yaml)
`watcher.nodeSelector` | Node labels for pod assignment | `{}`
`watcher.affinity` | Pod affinitiy | `[]`
`watcher.tolerations` | Node taints to tolerate| `{}`

## Admission Webhook
Parameter | Description | Default
--- | --- | ---
`admission.image.repository` | The admission webhook image repository | `infuseai/primehub-admission`
`admission.image.tag` |The admission webhook image tag | Please see [values.yaml](values.yaml)
`admission.image.pullPolicy` | The admission webhook image pull policy | `IfNotPresent`
`admission.resources` | Pod resource requests and limits | Please see [values.yaml](values.yaml)

## Bootstrap Job
Parameter | Description | Default
--- | --- | ---
`bootstrap.enabled` | If bootstrap job is enabled. | `true`
`bootstrap.username` | The name of init user | `phadmin`
`bootstrap.password` | The password of init user | random generated
`bootstrap.group` | The group of the init user | `phusers`
`bootstrap.image.repository` | The bootstrap image repository | `infuseai/primehub-bootstrap`
`bootstrap.image.tag` | The bootstrap image tag | Please see [values.yaml](values.yaml)
`bootstrap.image.pullPolicy` | The bootstrap image pull policy | `IfNotPresent`
`bootstrap.resources` | Pod resource requests and limits | Please see [values.yaml](values.yaml)

## Primehub Controller
Parameter | Description | Default
--- | --- | ---
`controller.replicaCount` | The number of primehub controller replicas | `1`
`controller.image.repository` | The primehub controller image repository  | `infuseai/primehub-controller`
`controller.image.tag` | The primehub controller image tag | Please see [values.yaml](values.yaml)
`controller.nodeSelector` | Node labels for pod assignment | `{}`
`controller.proxy.image.repository` | The kube-rbac-proxy image repository | `gcr.io/kubebuilder/kube-rbac-proxy`
`controller.proxy.image.tag` | The kube-rbac-proxy image tag | Please see [values.yaml](values.yaml)
`controller.resources` | Pod resource requests and limits | Please see [values.yaml](values.yaml)
`controller.affinity` | Pod affinitiy |  `[]`
`controller.tolerations` | Node taints to tolerate| `{}`

## Group Volume
Parameter | Description | Default
--- | --- | ---
`groupvolume.enabled` | If enabl the groupvolume controller | `true`
`groupvolume.storageClass` | The storage class of the NFS underlying pvc | *Required if enabled*
`groupvolume.replicas` | The number of metacontroller webhook replicas | `1`
`groupvolume.image.repository` | The metacontroller webhook image repository | `metacontroller/jsonnetd`
`groupvolume.image.tag` | The metacontroller webhook image tag | Please see [values.yaml](values.yaml)
`groupvolume.image.pullPolicy` | The metacontroller webhook image pull policy | `IfNotPresent`
`groupvolume.nfs.image.repository` | The NFS image repository | `k8s.gcr.io/volume-nfs`
`groupvolume.nfs.image.tag` | The NFS image tag | Please see [values.yaml](values.yaml)
`groupvolume.nfs.image.pullPolicy` | The NFS image pull policy | `IfNotPresent`
`groupvolume.resources` | Pod resource requests and limits | Please see [values.yaml](values.yaml)
`groupvolume.nodeSelector` | Node labels for pod assignment | `{}`
`groupvolume.affinity` | Pod affinitiy | `[]`
`groupvolume.tolerations` | Node taints to tolerate| `{}`

## Gitsync Dataset
Parameter | Description | Default
--- | --- | ---
`gitsync.enabled` | If enable the gitsync controller | `true`
`gitsync.replicas` | The number of metacontroller webhook replicas | `1`
`gitsync.image.repository` | The metacontroller webhook image repository | `metacontroller/jsonnetd`
`gitsync.image.tag` | The metacontroller webhook image tag | Please see [values.yaml](values.yaml)
`gitsync.image.pullPolicy` | The metacontroller webhook image pull policy | `IfNotPresent`
`gitsync.resources` | Pod resource requests and limits | Please see [values.yaml](values.yaml)
`gitsync.nodeSelector` | Node labels for pod assignment | `{}`
`gitsync.tolerations` | Node taints to tolerate| `{}`
`gitsync.affinity` | Pod affinitiy | `[]`
`gitsync.daemonset.delayInit` | |
`gitsync.daemonset.image.repository` | The [gitsync](https://github.com/kubernetes/git-sync) image repository | `k8s.gcr.io/git-sync`
`gitsync.daemonset.image.tag` | The gitsync image tag | Please see [values.yaml](values.yaml)
`gitsync.daemonset.image.pullPolicy` | The gitsync image tag pull policy | `IfNotPresent`

## Jupterhub
Parameter | Description | Default
--- | --- | ---
`jupyterhub.*` | The [configuration of zero-to-jupyterhub chart](https://zero-to-jupyterhub.readthedocs.io/en/latest/reference/reference.html)| Please see [values.yaml](values.yaml)
`jupyterhub.primehub.keycloakClientId`| | `jupyterhub`
`jupyterhub.primehub.scopeRequired` | The keycloak scope is required to use jupyterhub |  `""`
`jupyterhub.primehub.startnotebook` | A map to inject the start notebook scripts. The key is the filename, the value is the script content | `{}`
`jupyterhub.primehub.startNotebookConfigMap` | The configmap name for start notebook scripts| `start-notebook-d`
`jupyterhub.primehub.kernelGateway` | If kerenel gateway enabled | `false`
`jupyterhub.primehub.authRefreshAge` | The authentication refresh rate. | `-1`
`jupyterhub.primehub.node-affinity-preferred`| The affinity setting for jupyter notebook | `[]`
`jupyterhub.primehub.node-affinity-required` | The affinity setting for jupyter notebook  | `[]`
`jupyterhub.primehub.pod-affinity-preferred` | The affinity setting for jupyter notebook | `[]`
`jupyterhub.primehub.pod-affinity-required` | The affinity setting for jupyter notebook | `[]`
`jupyterhub.primehub.pod-anti-affinity-preferred` | The affinity setting for jupyter notebook | `[]`
`jupyterhub.primehub.pod-anti-affinity-required` | The affinity setting for jupyter notebook | `[]`

To run a script for each notebook startup, you can configure in this way. Note that this script is run under `root` user
```
jupyterhub:
  primehub:
    startnotebook:
      hello.sh: |
        echo "hello"
        echo "world"
```

## Dataset Upload
Parameter | Description | Default
--- | --- | ---
`datasetUpload.enabled` | If dataset upload server enabled | `true`
`datasetUpload.interface.tusd.resources` | Pod resource requests and limits | Please see [values.yaml](values.yaml)
`datasetUpload.interface.webFrontEndImage.repository` | The dataset upload frontend image repository | `infuseai/dataset-upload-web-front-end`
`datasetUpload.interface.webFrontEndImage.tag` | The dataset upload frontend image tag | Please see [values.yaml](values.yaml)
`datasetUpload.interface.webFrontEndImage.pullPolicy` | The dataset upload frontend image pull policy | `IfNotPresent`
`datasetUpload.interface.webFrontEndImage.resources` | Pod resource requests and limits | Please see [values.yaml](values.yaml)
`datasetUpload.metacontrollerHooks.replicas` | The number of metacontroller webhook replicas | `1`
`datasetUpload.metacontrollerHooks.image.repository` | The metacontroller webhook image repository | `metacontroller/jsonnetd`
`datasetUpload.metacontrollerHooks.image.tag` | The metacontroller webhook image tag | Please see [values.yaml](values.yaml)
`datasetUpload.metacontrollerHooks.image.pullPolicy` | The metacontroller webhook image pull policy | `IfNotPresent`

## Image Builder
Parameter | Description | Default
--- | --- | ---
`customImage.registryEndpoint` | The endpoint of the registry server. `docker login <server>` | *required if enabled*
`customImage.registryUsername` | The username of the registry server. | *required if enabled*
`customImage.registryPassword` | The password of the registry server. | *required if enabled*
`customImage.pushRepoPrefix` | The repository prefix for all built images. The built image will be `<prefix>/my-image-name:<hash>` | *required if enabled*

If the registry password contains multiple lines, for example, json keyfile from GCR (Google Container Registry). You can configure in this way.

```
customImage:
  registryEndpoint: https://gcr.io
  registryUsername: _json_key
  registryPassword: |-
    password_line_1
    password_line_2
```

Please note the `|-` string, it's required for multiple line string in yaml format.

## Job Submission
Parameter | Description | Default
--- | --- | ---
`jobSubmission.enabled` | Enable the job submission | `false`
`jobSubmission.workingDirSize` | The size of ephemeral storage for working directory. The format of unit is defined in [kubernetes document](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) | `5Gi`
`jobSubmission.defaultActiveDeadlineSeconds` | Default timeout (seconds) for a running job | `86400`
`jobSubmission.defaultTTLSecondsAfterFinished` | Default TTL (seconds) to delete the pod for a finished job | `604800`
`jobSubmission.nodeSelector` | The default [node selector](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector) for the underlying pod | `{}`
`jobSubmission.affinity` | The default [affinity](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) setting for the underlying pod | `{}`
`jobSubmission.tolerations` | The default [tolerations](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) setting for the underlying pod | `[]`

## Admin Notebook
Parameter | Description | Default
--- | --- | ---
`adminNotebook.enabled` | | `false`
`adminNotebook.replicaCount` | The number of admin notebook replicas | `1`
`adminNotebook.image.repository` | The admin noteoobk image repository | `infuseai/primehub-admin-notebook`
`adminNotebook.image.tag` | The admin noteoobk image tag | Please see [values.yaml](values.yaml)
`adminNotebook.image.pullPolicy` | The admin noteoobk image pull policy | `IfNotPresent`
`adminNotebook.resources` | Pod resource requests and limits | Please see [values.yaml](values.yaml)
`adminNotebook.nodeSelector` | Node labels for pod assignment | `{}`
`adminNotebook.affinity` | Pod affinitiy | `[]`
`adminNotebook.tolerations` | Node taints to tolerate| `{}`
`keycloakGateway.image.repository` | The keycloak gateway image repository| `infuseai/primehub-admin-notebook`
`keycloakGateway.image.tag` | The keycloak gateway image tag | Please see [values.yaml](values.yaml)

# Developer Notes
## Update Scripts and CRDs

If the image tag is changed, the scripts and crds also needs to be updated. Run the following commands to update.
This command will sync scripts folder and crd yaml files from [Primehub Controller](https://github.com/InfuseAI/primehub-controller).

```
make primehub-controller-update
```
