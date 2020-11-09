# Changelog

## Upcoming
### What's New

## 3.1.1
- [Bugfix] Failed to view artifacts (ch13745)
- [Bugfix] Missing controller part of artifact retention (ch12303)
- [Bugfix] Fix job's timout not working issue (ch13584)
- [Bugfix] Fix airgap issue (ch13759)
- [Bugfix] Phfs in notebook is not editable when file is empty (ch13160)
- [Bugfix] Group name duplicate verification should case insensitive (ch13672)
- [Bugfix] Group name should transfer to lowercase when fetch artifacts info from minio

### Upgrade Notes
- The image version of `csi-rclone` image changes in this upgrade. The pods with phfs mounted need to restart after upgrading or they cannot access the phfs data.

## 3.1.0

### What's new

### Available in CE

- **Support Self-Signed Certificate**. Please refer to the enterprise edition documentation here. https://docs.primehub.io/docs/next/getting_started/configure-self-signed-ca
- **Server-to-Server Connection**.

#### Spawner

- Disable JupyterHub consecutive_failure_limit due to it will auto restart hub process (ch12897)
- [Bugfix] when user is spawning a jupyter pod, and user clicks "my server" in jupyterhub page, he will see the spawning status without header (ch12374)

#### Server-to-Server Connection

- Modify CI and e2e testing to use non-nip endpoint (ch12072)
- Update the doc for s2s connection (ch13029)
- Admin-notebook oidc supports both ex/internal keycloak (ch12039)
- JupyterHub oidc support both ex/internal URL (ch12037)
- Grafana oidc supports both ex/internal URL (ch12038)
- Review and modify primehub-console to support default use internal URL to connect keycloak for oidc (ch12109)
- [Bug] Cannot load page group-context ui page for non-admin user in in-cluster keycloak settings (ch12915)

#### Group-Context Sidebar Menu

- Remove group in list view column for job/schedule/model (ch12287)
- [Bugfix] when admin click "access server" in jupyterhub admin in new UI, it will open jupyterlab in iframe (ch12364)

#### Admin Portal

- Update Group setup ui in admin portal. (ch12940)
- Admin portal to user portal sidebar UX enhancement (ch12330)
- [Bugfix] Failed to create group (ch13273)

#### Users

- [Bugfix] Failed to connect user to group (ch12594)
- [Bugfix] Should not show the everyone group in the user page (ch12254)

#### Datasets

- Remove GPU/CPU quota columns from create/edit dataset tables (ch12469)
- [Bugfix] Datasets page is broken by clicking "Add" then clicking "Back" (ch12512)

#### Miscellaneous

- [CE][Popularity] README revamp (ch11958)
- [CE DX] Auto generate secrets & tokens if not provided (ch11353)

### EE Only

- **Support Job Artifact**: Users can output files generated from a job. The generated files can be downloaded later from the job UI.
- **Submit Job from Jupyter Notebook**: User can submit job by our notebook plugin on notebook directly.
- **On-Prem Usage Reporting**.

#### Job Submission

- Make job timeout configurable based on group and job (ch10336)
- Show resource information in job submission form (ch12332)
- PhJobs should change to Failed state if group is not found. (ch12092)
- Streamline headings/titles in Job Submission (ch10276)
- [Bugfix] cannot clone job when job contain specific char or newline char. (ch12179)
- [Bugfix] Submitted job by general users shows "{"code":"INTERNAL_ERROR","message":"Request failed with status code 403"}" in log (ch13189)


#### Job Submission Artifacts

- Design document Job submission artifacts (ch12305)
- Implement the artifact retention (ch12303)
- Implement the proxy to download API (ch12614)
- Job Submission UI: Implement Artifact Tab (ch12299)
- Implement graphql PHFS list API (ch12292)
- Implement artifacts copy logic (ch12294)
- Job submission UI: Move basic information from tab to upper pane. (ch12298)
- Implement REST download api (ch12302)

#### Submit Job from Jupyter Notebook

- Publish the jupyterlab extension to NPM (ch12799)
- Papermill: check installed and run notebook as a job (ch12911)
- Update base image to install extension and papermill (ch12800)
- Submit a notebook as a job in jupyterlab (ch11908)
- Improve the error message in graphql (ch12592)
- Add necessary environment variables in job submission controller for primehub-job package (ch11901)
- Using the ipywidgets to show the job status (ch11910)

#### PrimeHub Store

- [Bugfix] PrimeHub store settings would be missing if primehub store changes to enabled. (ch12644)


#### On-Prem Usage Reporting

- On-prem usage design document (ch11426)
- Tool to patch non usage-annotated pods (ch11823)
- Detailed usage report (ch12665)
- Change download file name of usage report (ch13121)


#### Miscellaneous

- Update the ceph default version to 13.2.7 (ch12885)
- Update base image's JL to 1.2.7 (ch12823)
- Simplified EE installation using public chart (ch10393)
- [Bugfix] The csi-nodeplugin-rclone DaemonSet need to add tolerations (ch13118)
- [Bugfix] Applying CRD yaml creates an item with wrong ID on Keycloak (ch12994)
- [Bugfix] A scheduled job is failed because pod already exists (ch11074)
- [Bugfix] PrimeHub 3.0 internal keycloak chart issues (ch12435)


## 3.0.1
### What's New

- [Bugfix] Fix spawning page issue (ch12374)

## 3.0.0
### What's New

### Available in CE

- **New PrimeHub UI.**: We change our portal ui to provide the better user experience.
- **SSH Bastion Server feature**. It's disabled by default in EE. To enable it, please follow https://docs.primehub.io/docs/next/getting_started/configure-ssh-server#enable-ssh-bastion-server-feature

#### New Primehub UI

- Group Context: Add a global group selector on top-right corner.
- Integrate our components in new entry portal.

#### SSH Server

- Merge ssh-proxy-server chart into PrimeHub chart #ch11274
- Install sshd should not block start-notebook.d #ch11962

#### Dataset

- Deprecate the launch group only features for dataset #ch11020

#### Miscellaneous

- Support default storageClass #ch11886
- Primehub Chart includes metacontroller and keycloak #ch11128


### EE Only

- **Primehub Usage(Alpha)**: [PrimeHub Usage](https://docs.primehub.io/docs/next/design/usage) provides administrators a overall insight of the usage of the PrimeHub.

#### Primehub Usage

- Verify usage data with stackdriver's log #ch11822
- Implement the usage report generator #ch6613
- Implement usage query API #ch6614
- Add big-query importer !1055
- Usage component docker/helm integration. #ch6616

#### Miscellaneous

- Add rook rgw support !1040
- Add legacy pod migration helper !1059
- Add pre upgrade script for primehub 3.0 !1049
- Remove kibana from primehub-upgrade script. #ch11710
- Add running pods monitor !1054
- Add pre-upgrade for v3.0, auto add KEYCLOAK_DEPLOY and METACONTROLLER_DEPLOY #ch11779
- [Feature] ch11886 Set rook-block storageclass as default storageclass !1057

### Breaking Changes
### Action Required

### Deprecated

- The annotation `dataset.primehub.io/launchGroupOnly` in dataset is deprecated now.

## 2.8.1

### Bugfixes

- Fix env dataset contain invalid character.
- Fix log component doesn't follow newest logs.

## 2.8.0

### What's New

- Admission Webhook now will ignore the pvcs that does not exist for users' jupyter pod and submitted job.
- **Object Store**: support csi-rclone installation

### Breaking Changes

- Upgrade helm version from 2.16.1 to 3.2.4
- Upgrade helm-diff version to 3.1.2
- Upgrade helmfile version to 0.125.0

### Action Required

Before primehub upgrade:
- Migrate helm from v2 to v3 by following https://helm.sh/blog/migrate-from-helm-v2-to-helm-v3/
- Install helm-diff v3.1.2 manually after helm 2to3 migration

After primehub upgrade:
- If helm-diff doesn't show anything but failed to apply, you might encounter this issue: https://github.com/helm/helm/issues/6642
  You might run into this if prometheus is installed:
  ```
  Error: UPGRADE FAILED: cannot patch "prometheus-operator-grafana" with kind PersistentVolumeClaim: PersistentVolumeClaim "prometheus-operator-grafana" is invalid: spec: Forbidden: is immutable after creation except resources.requests for bound claims
  ```
  To solve this, you have to specify `grafana.persistence.storageClassName` in `etc/helm_override/prometheus.yaml`

### Spawner

- SSH Server - controller for jupyter (ssh) service. #ch10291
- [Bugfix] Fix spawner when launching latest jupyter/base-notebook will go to classic notebook view #ch10914
- [Bugfix] SSH Server may make the jupyter server not accessible #ch10786

### PrimeHub Store

- Make minio pod managed by statefulset rather than deployment #ch11177
- Refine the installation experience for csi-rclone #ch10951
- Refactor the minio templates in primehub chart #ch10994

### Model Deployment

- Add effectiveGroups field in the User type of graphql #ch10618
- `csi-rclone` installation #ch10603
- Model Deployment Installation - Install end-to-end check #ch9976

### Admission

- [Bugfix] admission pvc-check failed to add an annotation to user submitted jobs #ch10754

### Miscellaneous

- Check AWS env work with auto scale #ch11026
- Refactor cluster shutdown script #ch10812
- Ignore any pvc that does not exist #ch10235
- Refine single node PrimeHub install script #ch10351
- Review and update full cluster shutdown document #ch10501

## v2.7.0
### What's New

- **Model Deployment(Alpha)**: [Optional] Setup `PRIMEHUB_MODE=deploy` flag to install model deployment feature only.
- **Image Builder**: It is general available now.
- **Model Deployment**: Enable model deployment by default when it is installed in deploy mode
- **JupyterHub**: Support non-standard images (not jupyter/base-notebook compatible)
- **API Auth**: User can get self api token for using graphql api on API auth page now.
- Model deployment client token.

### Action Required

- Before upgrading `primehub-grafana-dashboard-basic` chart, please touch `$(phenv --path)/helm_override/primehub-grafana-dashboard-basic.yaml`.

### Job Submission

- Job submission controller supports dataset with type nfs and hostpath #ch9630
- [Bugfix] Fix the issue of job list is out of sync #ch10219

### Model Deployment

- Model deployment client token - controller create ingress and secret according to clients spec #ch9884
- Move model deployment podmonitor from primehub chart to primehub-grafana-dasboard-basic chart. #ch9523
- Model deployment - upgrade dev-gce's ingress (rke) greater than or equals to 0.25.1 #ch9083
- Model deployment controller - check group is deployment enabled #ch8888
- Model deployment installation - enable model deployment for groups by default #ch9994
- Model Deployment Installation - Add CI test for model deployment only. #ch9975
- Replace seldon engine to executor #ch9511
- [Bugfix] Model Deployment Controller: The endpoint should use the scheme the helm value defined #ch9212

### Spawner

- Jupyter spawner support dataset with type nfs and hostpath #ch9629
- [Bugfix] JupyterHub Spawner page Show advanced settings and Datasets button don't work #ch9576
- [Bugfix] User can't spawn latest jupyter/base-notebook on version master@f6331bae #ch9792
- [Bugfix] jupyterhub shows wrong GPU "-" when user limit is 0 #ch9688
- [Bugfix]chown_extra.sh should not break notebook when fail #ch9372
- [Bugfix] using instanceType of floating point RAM will cause jupyter spawner page to show 'No group is configured for you to launch a server' #ch9578

### Image Builder

- Modify primehub-controller logic: allow empty image builder configs #ch9264

### Miscellaneous

- Add simple CI for PrimeHub CE chart #ch9011
- Basic checking when we prepare k8s upgrade #ch9619
- Confirm model deployment airgap ready #ch8993
- Create datasets test cases to cover more e2e coverage on spawner #ch9794
- Better PrimeHub default configuration with auto script #ch9667
- Refactor the primehub grafana dashboard basic #ch9447
- Update CRD dataset schema for nfs, hostPath, and pv manual provisioning #ch9628
- Update the model deployment dashboard for seldon engine 1.x #ch9282
- Add model deployment icon to user portal #ch9522
- [Bugfix] Hub redirect loop after switch user via primehub-console #ch9480
- [Bugfix] failed to pull image from private repo #ch9691
- [Bugfix] On AWS EKS cluster we can not cross zone to access pvc volume #ch8995
- [Bugfix] dataset upload is broken in http environment #ch9110

## v2.6.3

- [Bugfix] Fix zero display issue on Spawner page.

## v2.6.2

- [Bugfix] Spawner assets upgrade for click issue.

## v2.6.1

### What's New

- [Bugfix] Fix hub redirect loop after logout in portal.

## v2.6.0

### What's New

- **Model Deployment(Alpha)**: [Optional] Setup `PRIMEHUB_FEATURE_MODEL_DEPLOYMENT` flag to enable model deployment feature.

## v2.6.0

### What's New

- **Job Submission(Beta)** Job Submission functions are beta now. It is enabled by default. You can disable it by setting `PRIMEHUB_FEATURE_JOB_SUBMISSION` flag to `false`.
- Support K8S 1.17

### Breaking Changes

- **Job Submission(Beta)**: The mount path of the working directory is changed from `/workingdir` to `/home/jovyan`. This makes the path consistent with jupyter notebook.

### Job Submission

- Change the workingdir mount path #ch9042
- Remove job scheduler from user portal #ch8896
- [Bugfix] Job submission (logs) timezone should refers to PrimeHub System timezone setting #ch9128

### Model Deployment

- Implementation Design and  CRD  definition #ch6358
- Model deployment controller implementation (basic) #ch8574
- Metrics Collecting #ch7067
- Resource constraints #ch8806
- Change underlying implementation from seldondeployment to deployment. #ch9039

### Admission

- Admission Webhook allows resource validator to apply quota check only on group #ch9029

### Spawner

- Let NFS pods can be spread to all the nodes evenly. #ch7974
- [Bugfix] Safe mode with repo2docker might broken after jupyterlab 2.x #ch8549
- [Bugfix] Users switching causes Jupyter page redirecting issue after #ch8513

### Image builder

- Swap the order of pip and conda install #ch8492

### Miscellaneous

- Refactor AWS dev environment #ch9044
- Change keycloak helm chart repo to codecentric/keycloak #ch7333
- Upgrade rook version to support k8s v1.16.x on on-premise cluster (rook v1.0.x) #ch8099

## v2.5.3

### What's New

- [Bugfix] Users switching causes Jupyter page redirecting issue after #ch8513

## v2.5.2

### What's New

- Fix CI build

## v2.5.1

### What's New

- Fix rook upgrade issue.

## v2.5.0

### What's New

- **Kubernetes v1.16 supported.**
- **Prometheus-Operator v8 supported.**
- **New alpha feature: Scheduled job support.**: [Optional] Setup `PRIMEHUB_FEATURE_JOB_SUBMISSION` flag to enable job scheduler feature
- Define primehub-ready kuberentes in [primehub sites](https://docs.primehub.io/docs/dev-introduction) and better installation experience by `helm install`.

### Job Submission

- Submit the scheduled Job by job Controller #ch7777
- Schedules design document #ch7779
- Use system timezone in scheduled job #ch7954
- Refactor graphql setting from jobSubmission path in primehub helm chart #ch7154
- [Bugfix] group name contains underscore will break job submission #ch7985

### PrimeHub Console

- Have an indicator on user portal and job submission page to tell users it is not GA feature #ch7479
- Refactor admission webhook for graphql endpoint settings. #ch7325
- Add job scheduler icon on the user portal #ch8252
- [Bugfix] PrimeHub console landing page miss PrimeHub icon #ch8382
- [Bugfix] Fix user cannot use floating point RAM. e.g. 1.5 G #ch7605

### Spawner

- Show more details when k8s api was gone. #ch7758
- [Bugfix] Hub Spawner not working for admin spawning on behalf of user #ch8174

### Image Builder

- [Bugfix] image builder enable logic is wrong in dev-gce init script #ch7994

### Maintenance notebook

- Apply Istio authn/authz to admin-notebook #ch4805

### Miscellaneous
- Put our primehub version into helm app version #ch6735
- Group provisioned resources report, and quota recommendation #ch7170
- Modify the description of bootstrap generated group #ch8536
- In http setup, set sslRequired to none for all keycloak realms #ch8506
- Set USER env according to base image #ch8234
- Replace rollme of hub deployment #ch8322
- Dataset upload resources should not be overridden #ch8102
- Define the process to acquire credential and configure the primehub private images. #ch7323
- Allow installing primehub in namespace other than hub #ch6194
- Unify dev-kind/dev-gce/dev-gcp non-helm installer parts #ch4520
- [Bugfix] Fix installation problem in airgap #ch8477
- [Bugfix] Fix resource validation in airgap issue. #ch8479
- [Bugfix] primehub-group & primehub-gitsync svc selector is broken in 2.4 #ch8097
- [Bugfix] The playground introspection is not working #ch7935
- [Bugfix] Miss to touch metacontroller.yaml when upgrade primehub to 2.4 #ch7961
- [Doc] Primehub Installation/configuration guide (by helm install) #ch6200
- [Doc] Add Steps of set up license file in PrimeHub installation #ch8535
- [Doc] Document to setup a ph-ready k8s for single node on ubuntu #ch7795
- [Doc] Document to setup a ph-ready k8s on GKE #ch6201

### Breaking Changes

- Primehub will no longer support kubernetes v1.13.

#### Upgrade Notes

- **admission:** Change admission ca signing process.

  To migrate old admission webhook settings, please use `make primehub-upgarde` to upgrade primehub.

- **console images:** The environment variables `PRIMEHUB_CONSOLE_DOCKER_USERNAME` and `PRIMEHUB_CONSOLE_DOCKER_PASSWORD` are not required for production anymore. They are moved to dockerhub public repositories. But for development purpose, if these two variables are defined, primehub still use the original private repositories.
- [Optional] setup `PRIMEHUB_FEATURE_PROMETHEUS_OPERATOR_8` flag to upgrade prometheus-operator to version 8.

## v2.4.1

### What's New
- [Bugfix] Replace rollme of hub deployment #ch8332
- [Bugfix] Dataset upload resources cannot be overridden #ch8102
- [Bugfix] primehub-group & primehub-gitsync svc selector is broken in 2.4 #ch8097
- [Bugfix] Bug primehub console landing page miss primehub #ch8382
- [Bugfix] Bug group name contains underscore will break #ch7985

## v2.4.0

### What's New

- **License Key Management(Beta)** You can now obtain trial license and install PrimeHub and experience EE .
- **Make persistent home directory under user path :** Make users be able to mount their persistence volume to `/home/jovyan/user`, by `Enable Safe Mode` in the spwaner advanced settings.
- **Support repo2docker image:** Make images built by [repo2docker](docs/design/repo2docker.md) be able to run on PrimeHub.
- Upgrade default helm version from 2.11.0 to 2.16.1 - #ch3127
- Keycloak v8 supported.
- We rename our `Custom Image` feature to `Image builder`.

### Spawner

- "Used" metric of Group Resources on spawner should include resources used by jobs #ch6910
- Update `Safe Mode` tips #ch7309
- make primehub compatible with jupyter-repo2docker images #ch4866
- Refactor the way to integrate jupyterhub subchart. #ch6198
- Make persistent home directory optional in spawner #ch6765
- [Bugfix] Exceeded quota then wait for 5 mins will make spawner page to be "403 : Forbidden" #ch6895

### Jub Submission

- UI bugs and enhancements #ch6572
- The job duration should be computed since running stage #ch6741
- The detail page show more info about image/instance type #ch5701
- Change phjob phase naming: `ready change` to `preparing` #ch7134
- [Bugfix] phjob controller make the primehub-controller crashloopbackoff #ch6581
- [Bugfix] Controller got OOMKilled when jobs are more than ~1200 #ch6821
- [Bugfix] Controller crashes because of nil pointer. Job in Ready phase should have starttime and in Final phase should have finished time #ch6586
- [Bugfix] Job submission/Jupyterhub - datasets should have correct write permission #ch6143
- [Doc] Job Submission Design doc #ch4540

### License key management

- [License MVP] Beta release of License Key Management #ch5145
- [License MVP] Auto install pre-generated license in dev-gce & dev-gcp #ch6868
- [License MVP] Make the jupyterhub, hub and graphql pod restarts while cm/secret changes #ch7340
- [License MVP] Expose env variables in running job #ch6918

### Image Builder

- Add resource request/limit to custom image pod #ch6167
- Size of ephemeral storage for image builder should be configurable #ch7680
- Image builder feature default disabled. #ch6421
- [Bugfix] admin can't build larger custom image #ch6412
- [Doc] Rename Custom Image/Build Image with Image Builder #ch7051

### Miscellaneous

- [Bugfix] Grafana drilldown doesn't work after our URL rewrite #ch6248
- [Bugfix] "Cleanup orphan PVC" in maint notebook shows non-orphan PVCs #ch7307
- [Bugfix] job runs by root instead of jovyan #ch6589
- [Bugfix] primehub install scripts broken #ch6651
- [Bugfix] non-admin user can't login primehub with keycloak 8 #ch7716
- [Bugfix] The 'Back to Portal' link is not back to user portal #ch5254
- [Bugfix] Take gpu image when instance type is cpu #ch6504
- [Doc] Primehub Architecture: write the architecture document #ch6106
- [CI] remove maintenance notebook #ch4912
- Refactor the primehub helm chart, move sub-charts to primehub chart #ch5514
- Create group volume in primehub-console rather than hub. #ch3205
- Bump Canner UI to 3.15.1.
- E2e test enhancement.
- Make primehub group nfs and git sync as part of primehub helm chart. #ch3409

### Breaking Changes

- The primehub chart value structure change. The `primehub-console`, `primehub-prerequisites`, `admin-notebook` is not used anymore.
- Primehub Enterprise Edition now requires a license to unlock full features. Please install a license after upgrade.

#### Upgrade Notes

- If you didn't prepare a license file, your cluster will active by default license.
- Primehub chart value path changed. Please modify the configuration in `$(bin/phenv --path)/helm_override/primehub.yaml`

  Old path | New path
  ----|----
  `primehub-prerequisite.hub.startnotebook` | `jupyterhub.primehub.startnotebook`
  `primehub-prerequisite.*` | not used
  `primehub-console.keycloak` | `primehub.keycloak`
  `primehub-console.keycloak.url` | not used. env `KC_SCHEME` and `KC_DOMAIN` instead
  `primehub-console.ui.*` | `console.*`
  `primehub-console.watcher.*` | `watcher.*`
  `primehub-console.graphql.*` | `graphql.*`
  `admin-notebook` | `adminNotebook`
  `jupyterhub.custom.adminEndpoint` |  not used.
  `jupyterhub.custom.keycloakHost` | not used. env `KC_DOMAIN` instead
  `jupyterhub.custom.keycloakScheme` | not used. env `KC_SCHEME` instead
  `jupyterhub.custom.keycloakRealm` | not used. env `KC_REALM` instead
  `jupyterhub.custom.primehubRolePrefix` | `primehub.keycloak.rolePrefix`
  `jupyterhub.custom.*` | `jupyterhub.primehub.*`
  `*.ingress` | `ingress`

  For ingress customization, we unify the ingress setting to `ingress.*` rather than `<component>.ingress.*` in each component.

- **groupvolume&gitsync:** Change the primehub-groupvolume and primehub-gitsync installation from manually install to primehub helm chart.

  To migrate groupvolume and gitsync to primehub helm chart, please use `make primehub-upgarde` to upgrade primehub.

  If don't want to migrate, please add the following config into `helm_override/primehub.yaml`

  ```yaml
  groupvolume:
    enabled: false
  gitsync:
    enabled: false
  ```

- **groupvolume:** Now, group volume (pvc and pv) is created when creating a group (with a shared volume) in admin UI. And may need to change the default storage class and group volume storage class helm settings.

  If you overwrite
  ```yaml
  jupyterhub:
    custom:
      groupVolumeStorageClass: ""
      groupVolumeAnnotations:
        primehub-group-sc: standard
  ```
  or
  ```yaml
  graphql:
    primehubGroupSC: standard
  ```
  Please move your overwritten settings into
  ```yaml
  primehub:
    sharedVolumeStorageClass: ""
  groupvolume:
    storageClass: standard
  ```


## v2.3.0

### What's New

- **Custom Image (Beta):** Custom image feature is now in beta!
- **Job Submission (Alpha):** Setup `PRIMEHUB_FEATURE_JOB_SUBMISSION` flag to enable job submission feature!
- **Document Site:** Our [new document](https://docs.primehub.io/) site is now online!

### Changes

#### Upgrade Notes

- **Jupyterhub:** Change `refresh_user` call frequency from 300 seconds to every time when Jupyterhub API called. This behavior will consume more Keycloak resources. If Keycloak is unbearable in production environment, we can use `jupyterhub.custom.auth_refresh_age` in `helm_override/primehub.yaml` to configure the frequency of calling `refresh_user`.

#### Spawner

- [UI] Spawner UI update according to window size #ch5245
- [UI] Memory in group resource should display in "xxxGB" format - #ch5073
- [UI] Simplify group selection dropdown - #ch5158

#### Custom Image

- Put jobs in updated_at desc order - #ch5325
- [UI] Improve `Packages` textarea - #ch5326
- [UI] Add Build Images page on Admin-UI - #ch3075
- [Doc] Update AdminUI with Build Images page - #ch4005

#### Job Submission

- PHJob Controller - Terminate all pods once the phjob reaches activeDeadlineSeconds - #ch5033
- PHJob Controller - advance spawn logic - #ch4180
- PHJob Controller - Allow to delete pod when job complete after a given time - #ch5032
- PHJob controller - Requeue if the reason of failed is due to admission - #ch4542
- [Bug] PHJob controller - spawner logic bug - #ch5230
- [Bug] Job Submission - always failed on demo a #ch5970
- [Bug] Job page is cached so that the UI is not shown currectly. #ch5884

### Bugfix

- [Bug] Fix dev-gce use wrong image for calico controller #ch6235
- [Bug] Fix resources-validation-webhook can not allow username content '@' on demo environment #ch5774
- [Bug] Fix OTP message in account creation process #ch5951
- [Bug] Fix maintenance notebook cleanup orphan pvc is broken #ch5822
- [Bug] Fix user can't logout properly in primehub-console #ch5800
- [Bug] Fix admin bit removal didn't sync to jupyterhub - #ch5827

### Security

- [Bug] Fix primehub-console insecure cookies - #ch5637

## v2.2.2

### Bugfix

- [Bug] Resources-validation-webhook can not allow username content '@' - #ch5774
- [Bug] Backport new Primehub theme version to 2.2 - #ch5951
- [Bug] Move Primehub-admission image to docker hub - #ch5323

## v2.2.0

### What's New

- **Custom Image:** Admin now can build images with custom packages which include APT, pip and conda.

- **Admission:** We use admission to check resources now. Please reference [admission document](docs/design/admission.md) for more detail.

- **Dataset Upload (Beta):** For a dataset with pv type, it can run a dataset upload server which allow resumable upgrade and disable upload progress.

### Breaking Changes

### Action Required

- To enable Custom Image, you need to set `PRIMEHUB_FEATURE_CUSTOM_IMAGE=true` and it requires new environment variables:
  - `PRIMEHUB_CONTROLLER_CUSTOM_IMAGE_REGISTRY_ENDPOINT`: Registry endpoint (e.g. `https://gcr.io`)
  - `PRIMEHUB_CONTROLLER_CUSTOM_IMAGE_REGISTRY_USERNAME`: Registry username
  - `PRIMEHUB_CONTROLLER_CUSTOM_IMAGE_REGISTRY_PASSWORD`: Registry password
  - `PRIMEHUB_CONTROLLER_CUSTOM_IMAGE_REPO_PREFIX`: Prefix for image. (e.g. 'gcr.io/infuseai' for 'gcr.io/infuseai/primehub-controller:be20ee69c5')

### Features

- [Dataset Upload v1] Dataset Upload V1 - Beta - #ch5084
- [Dataset Upload v1 Make dataset upload endpoint configurable in primehub console - #ch4132
- [Admission Hook GA] Make ENABLE_ADMISSION default - #ch2476
- [Spawner v1] Spawner style issue when server fails to start - #ch5004
- [Spawner v1] The 'Start Notebook' button should always in the bottom - #ch4636
- [Spawner v1] JH api endpoint and rendering for group resource usage stats - #ch3595
- [Spawner v1] Update spawner page to apply the new design and show dataset info - #ch3598
- [Spawner v1] Spawner Progress page redesign - #ch1550
- [Custom Image v1] [Custom image v1] Allow to disable custom image by default - #ch4890
- [Job Submission: MVP] PhJob Controller - implement requeue logic on ready state timeout - #ch4473
- [Job Submission: MVP] Modify resource validation logic in jupyter and admission - #ch4466
- [Job Submission: MVP] PHJob Controller - running pod failed reason should copy to phjob reason. - #ch4469
- [Job Submission: MVP] PhJob Controller - helm integration - #ch4475
- [Job Submission: MVP] PHJob Controller - implement job cancellation - #ch4472
- [Job Submission: MVP] PhJob Controller - make working directory mount to a ephemeral storage - #ch4476
- [Job Submission: MVP] Survey resource constraint solutions - #ch3588
- [Job Submission: MVP] [cp1] PHJob Controller - basic workload - #ch3790
- [Job Submission: MVP] [cp1] Provide sample PHJob definition - #ch3591
- [Custom Image v1] Custom image v1 add feature flag to console - #ch5384
- [Custom Image v1] Make primehub-controller to be helm managed - #ch4157
- [Custom Image v1] Implement an controller to watch ImageSpec and create the follow-up jobs - #ch3077
- [Custom Image v1] Implement the job log tailing API - #ch3787
- [Workspace v1] Workspace: manage workspace and create resources in different workspace - #ch1002
- All pods should have cpu/memory limits - #ch3882
- Make primehub keycloak theme as the default installation. - #ch3241
- Allow to bootstrap by service account instead of master account. - #ch4443
- Change Primehub-keycloak-theme registry repo form gitlab to dockerhub - #ch4424
- Disable kubernetes service links in pods - #ch416
- Revisit monitor scripts to see if alert manager is now adequate - #ch3463
- Gitsync daemonset should have toleration - #ch4013
- Check 401 service account token and fix them - #ch3920

### Security

### Bugfix

- [Bug] graphql might not response to client anymore - #ch4759
- [Bug] When user logout and login again immediately, he will see error message. - #ch3045
- [Bug] The newer JupyterLab won’t download image files - #ch4036
- [Bug] Grafana logout button is broken - #ch4692
- [Bug] When user choose a group with no dataset in spawner UI, the information in datasets section won't update - #ch4831
- [Bug] Change script path in kc_everyone_group_default_limit.sh - #ch4452
- [Bug] Admin dashboard discard button doesn't work - #ch4392
- [Bug] Unable to remove logo from primehub admin console - #ch4668
- [Bug] New spawner page group usage bug - #ch4601
- [Bug] Fix login dialog in the primehub theme when admin enables oauth providers - #ch3266
- [Bug] Fix OTP page - #ch5540
- [Bug] Fix Airgap rek init config - #ch5276

### Third Party

### Document

- [Doc] Create PrimeHub Manual, Admin UI Manual in Markdown format - #ch3757
- [Doc] Update PrimeHub Manual with new progress bar in spawner - #ch3741

## v2.1.4

### Bugfix

- [Bug] fix zh-TW OTP message in primehub-keycloak-theme - #ch5540
- [Bug] primehub-console insecure cookies - #ch5637

## v2.1.3

### Bugfix

- [Bug] Fix missing images in airgap environment - #ch5276

## v2.1.2

### Bugfix

- [Bug] When user logout and login again immediately, he will see error message. - #ch3045

## v2.1.1

### Feature

- make dataset upload beta - #ch5084

### Bugfix

- When user logout and login again immediately, he will see error message. - #ch3045
- unable to remove logo from primehub admin console - #ch4668
- admin dashboard discard button doesn't work - #ch4392
- fix grafana dashboard logout issue - #ch4692

## v2.1.0

### What's New

The main themes of this release are:

- **User Portal (GA)**: A single user portal for user to access all the components and the admin console.
- **GPU/CPU Image selection**:  Admin can provide different image name for GPU/CPU
- **Dataset PVC Creation:** Support to create dataset PVC from admin console.
- **Meta Chart:** Since the 2.0 release, the meta chart is enabled by default. In release 2.1, the bootstrap script is run in the cluster and triggered when running helm install and upgrade.

### Breaking Changes

N/A

### Action Required

- Because `PRIMEHUB_FEATURE_USER_PORTAL` is enabled by default, there are some action required:
  - For default installation, the `PRIMEHUB_SCHEME`, `PRIMEHUB_DOMAIN`, `KC_SCHEME`, `KC_DOMAIN` is required environment now. For definition, please reference [configuration document](docs/administration/configuration.md)
  - modify keycloak client `grafana-proxy` redirect URIs to `https://<PRIMEHUB_DOMAIN>/grafana/*`
- Image has new spec attributes `type` and `urlForGpu` now, those two new attrs are used for seamlessly picking different image by type in spawner. For migrating existing images, please run `modules/upgrade/optional/add_gpu_cpu_type_to_images.sh`
- Set a new environment variable `PRIMEHUB_STORAGE_CLASS`. For rke installation, please set it to `rook-block`. For dev-gcp, set it to `standard`. For dev-gce, set it to `rook-block`. For dev-kind set it to `local-path`. It is the storage class setting for all RWO pvc usage.

### Features

- Make User portal as default landing page #ch2574
- admin-console should have a nav link back to portal #ch2859
- Add Grafana to default list of user portal #ch2981
- Adjust the application path #ch3495
- Make the banner consistence in the user portal and admin console #ch3498
- Unify primehub-console's navbar style #ch3498
- unified ingress: deprecate PH_DOMAIN #ch1727
- unified ingress: grafana #ch1725
- update checklist for PrimeHub installation #ch2937
- Tweaks for User Portal #ch2674
- remove deprecated variables #ch3772
- [Dataset] Admin Dashboard provides UI to create dataset pv-type pvc. #ch1794
- Move dataset upload chart to metachart. #ch3065
- In meta chart, use Job to perform idempotent upgrade #ch1238
- Add images type (gpu/cpu/universal) on images list page #ch3661
- Update image type wording `both` to `universal` #ch3393
- conditional spawner options for image and GPU/CPU #ch2642
- admin-ui support new ux-behavior to set up GPU/CPU in 1 image crd #ch2638
- set maintenance notebook files to read only #ch1920
- Make primehub-admission helm managed #ch1735
- parameterize primehub-admission by helm-chart #ch1749
- Refactor admission flask server #ch1909
- crd openapi schema #ch2370
- Support validation schema defined in the CRD (Image, InstanceType and Dataset) #ch2370
- Script to check if the service account token valid #ch3764
Workspace
- Provide a tool to detect and fix orphan mount & rbdmap #ch3460
- Create `ImageSpec` and `ImageSpecJob` CRD #ch3807
- [Custom image v1] Evaluate Tekton pipelines for image building #ch3076
- [Custom image v1] Evaluate if metacontroller satisfy the operator needs #ch3086
- [Custom image v1] Setup Google container registry for storing built images #ch3083
- Design Training Job Submission MVP #ch2724
- Workspace: Admin Console UI Changes #ch1278

### Security

- k8s CVE-2019-11253 mitigation and advisories #ch3808

### Bugfix

- [BUG] bootstrap image incompatible with the latest code (GPU, CPU feature) #ch3676
- [BUG] memory resource literal should convert to bytes #ch3956
- [Bug] 'feature/ch2436/provide-scripts-to-delete-orphan-user-group' break the ci job 'build:infra-upgrade-test-previous' #ch3701
- [Bug] Attributes in everyone group is removed after editing "Default User Volume Capacity" #ch3007
- [Bug] Default USER_PORTAL cause CI fail in infra-upgrade-test-previous #ch3934
- [Bug] If numeric password is not allowed in bootstrap #ch3339
- [Bug] Resource validator should check all container resource's usage #ch3414
- [Bug] The `make init` generated .env incorrect. #ch3213
- [Bug] User can't go to login page after logout from JupyterHub #ch2786
- [Bug] When admin updates group permissions for some instances & images, hub won't auto update for users #ch3041
- [Bug] When instance type set memory with fraction, cannot spawn #ch4082
- [Bug] When user choose a cpu or gpu instance, then choose the other instance of same type, the image list shouldn't be reset #ch3422
- [Bug] feature/ch2574/make-user-portal-default break the ci job 'build:infra-upgrade-test-latest' #ch3700
- [Bug] graphql-server should terminate when oidc refresh token fails #ch2358
- [Bug] kernel-gateway cannot see GPU device #ch3641
- [Bug] the volume size of pv dataset is incorrect in demo.b #ch3629
- [Bug] when user create an instance type without overcommitting values, and click the edit button again, it shouldn't show overcommitting enabled. #ch3649
- [Bug][CI][Kind] no instance type and image can be found #ch3991
- cloud provisioner - quota on everyone group #ch1957
- user portal broken after group removal #ch3003
- Reproduce the group volume migration issue and find the solution #ch3012
- investigate dev-gcp's use of load balancer #ch3933

### Third Party

- Upgrade cert-manager #ch2673
- Upgrade Grafana dashboard to 6.3.0 and support unified ingress #ch1725
- followup node-problem-detector #ch2088
- [gpu] a preview image contains nvdashboard plugin (predefine layout for UX) #ch3768
- Survey nvdashboard jupyter plugin #ch2220

### Document

- build docs and provide as help site as part of primehub installation #ch1746
- open source license files #ch2291
- [Doc] Update ZD PrimeHub Manual with conditional spawner scenario #ch3389
- [Doc] Update dataset page on ZD with two new features #ch2900
- Beta Features Policy (eg Dataset Upload) #ch3816
- Polish PrimeHub-Site to release-ready #ch2947
- Spec: Hub UI can show resources usage for users' group before launch #ch391
- Spec: design the architecture to integrate user portal, workspace, and application. #ch2976
- Write design document for dataset upload #ch2503
- Write document for primehub-ee metachart #ch2875


## v2.0.0

### Breaking Changes

- PrimeHub is managed by a single meta chart


### Action Required

- **[Downtime Required] Migrate to metachart.** Please follow the instructions in the [migration document to v2.0](modules/upgrade/migrate-v2.0/migrate-v2.0.md)
- **Dataset PVC** Please configure `primehubGroupSC` at etc/helm_override/primehub.yaml. For example, set `standard` storage-class for GKE:
  ```yaml
  primehub-console:
    graphql:
      primehubGroupSC: standard
  ```
  The primehub-console needs a storage-class to create dataset pvc.

Change `starndard` to other pvc storage class if needed.
- [Optional] setup `PRIMEHUB_FEATURE_ENABLE_KERNEL_GATEWAY` flag to enable jupyter separated kernel feature
- [Optional] setup `PRIMEHUB_FEATURE_DATASET_UPLOAD` flag to enable dataset upload feature

### Deprecated

- **Configuration in `${primehub}/etc`**. Configuration files should locate in `~/.primehub/config/$(kubectl config current-context)` instead of `${primehub}/etc`. The preferred path can also by retrieved by the command `${primehub}/bin/phenv --path`. For more information, please see [customization document](docs/design/customization.md)


### Features

- [admin] Admin Dashboard provides UI to create dataset pv-type pvc. #ch1794
- [rke] Configure csr-approval feature enabled by default #ch1641
- [primehub] Make the meta chart the default installation #ch2096
  - [dev] Use metachart in dev-gce and dev-gcp installation. #ch2874
  - [airgap] Make sure metachart can be installed in airgap environment #ch2876
- [primehub] Upgrade primehub-console to v3.5.2 (backport)

### Bugfix

- [admin] Attributes in everyone group is removed after editing "Default User Volume Capacity" #ch3007
- [hub] Bring scheduled-maintenance anti affinity back #ch2667
- [hub] Refresh user state after the administrator reconfigred settings #ch2676
- [hub] When admin updates group permissions for some instances & images, hub won't auto update for users #ch3041 (backport)

### Documents

- [primehub] Update PrimeHub 2 migration documents to avoid lost role binding #ch3023
- [hub] Write a design document for persistence storage for notebooks #ch1119
- [admin] Write design document for graphql #ch1116

## v1.8.2

### Security

- [CVE-2019-9512] Upgrade nginx-ingress chart to 1.17.1 (app version 0.25.1)

## v1.8.1

### Bugfix

- Fix the issue that user can't launch instance when its CPU/memory requests are disabled. #ch2475
- Fix group sorting error in spawner page. #ch2471

## v1.8.0

### Action Required

- [Optional] Disable image and instance type customization
  Set env `READ_ONLY_ON_INSTANCE_TYPE_AND_IMAGE=true` will disable image and instance type customization.

- [Optional] For external keycloak installation, install `keycloak-tools` to enable keycloak idempotent upgrades.

  ```
  kubectl apply -f modules/bootstrap/keycloak-tools.yaml
  ```

- [Optional] Apply pod's image mutation

  Label any namespaces which want to apply pod's image replcaing. For example:

  ```
  kubectl label ns hub primehub.io/image-mutation-webhook=enabled
  ```

  In an airgap environment, that should be all namespaces.  This version, it keeps both PRIMEHUB_AIRGAPPED and image-mutation for backward compatible.

- [Optional] Portal Default Cover

  Since 1.8.0, we add serveral default cover images for portal link, you can override ui.portalConfig setup to use it:
    - Gitlab: `/admin/default-covers/gitlab.png`
    - Mattermost: `/admin/default-covers/mattermost.png`
    - Jupyter: `/admin/default-covers/jupyter.png`
  default portal setup in `modules/charts/primehub-console/values.yml`:
  ```
  portalConfig: |
    services:
      # Service portal setup example:
      # - name: Example
      #   uri: "https://example.com"
      #   image: "/admin/default-covers/default.png"
      #   adminOnly: true | false
      #- name: Gitlab
      #  uri: "https://gitlab.com/infuseai"
      #  image: "/admin/default-covers/gitlab.png"
      - name: JupyterHub
        uri: "/hub"
        image: "/admin/default-covers/jupyter.png"
      - name: Support
        uri: "https://infuseai.zendesk.com/hc/en-us"
        image: "/admin/default-covers/support.png"
      - name: JupyterHub Admin
        uri: "/hub/admin"
        adminOnly: true
        image: "/admin/default-covers/jh-admin.png"
      - name: Admin Dashboard
        uri: "/admin/cms"
        image: "/admin/default-covers/admin-ui.png"
        adminOnly: true
      - name: Maintenance Notebook
        uri: "/admin/maintenance"
        image: "/admin/default-covers/notebook.png"
        adminOnly: true
    welcomeMessage: >
  ```

### Features

- Add new icons in user protal. #ch1860
- Implement an operator to control dataset upload server. #ch1796
- Spawner UI will order instanceTypes & images options in alphabetical order. #ch1742
- Use PrimeHub logo in JupyterHub navbar and can be used to redirect to user portal. #ch1740
- Support feature toggling infrastructure to provide an alternative to maintaining multiple source-code branches. #ch1675
- Add new template condition for readonly image and instanceType. #ch1595
- Design document for JupyterHub integration. #ch1114
- User won't be stuck in spawning page when resources is not enough. #ch1020
- Support idempotent bootstrap and upgrade for external keycloak setup.

### Bugfix

- Fix out of range issue when resizing user volume. #ch2125
- Fix missing space issue in "connect existing groups" button. #ch2070
- Fix deprecated fields in z2jh to avoid warning and provide forward compatibility. #ch231
- Fix the issue that group loading too long if there are too many users. !453
- Fix unexpected error when user without any dataset in launch group. !445
- Fix user storage capacity unit. !440
- Fix typo of terraform load module. !437

## v1.7.0

- Fix missing change image.txt !421
- Bump admin-notebook version with user and group cleanup !420
- Speed up OSD backfill !419
- Fix jupyterhub chart uses wrong image for airgap !418
- Remove skip deps for old helmfile !417
- Fix ci docker version !415
- Write design document for CRDs !414
- Refine primehub version provides way !413
- Support admission hook
- Rewrite template logics !411
- K8S ca signer checker !410
- Use feature flag to support old convention for group volume !407
- Update notebook image tag and move some fixed config into admin notebook image !406
- Add ansible playbook for migrate aia bluestore !405
- Add User portal mvp admin shows regular user !404
- Unify admin hub ingress !402
- Fix: launchGrouponly should work for each type !401

### Breaking Changes

- Replace admin-ui with primehub-console
- Unify domain name

### Action Required

- **[Downtime Required] Migrate primehub-groupvolume.**

  After upgrade v1.7.0 primehub-groupvolume, need to run migration script to migrate exist project-volume and dataset-volume.

  After migrating primehub-groupvolume until running the migration process, user pod can not access the data in project and dataset volume.

  For the production environment, it's better to schedule downtime upgrade with customer, or we need to let customer known user will encounter data access error during the upgrade process.

  - RKE environment will run `rke_migration.sh` script for migration or follow the migration process provided in `READMD.md`.
  - GKE environment will run `gke_migration.sh` script for migration.
  (See `modules/primehub-groupvolume-nfs/README.md` for more info.)

- **Migrate admin-ui to primehub-console**

  1. Add the environment variables for image pull secret to `.env`

      ```
      PRIMEHUB_CONSOLE_DOCKER_USERNAME=
      PRIMEHUB_CONSOLE_DOCKER_PASSWORD=
      ```

      The value can be found from

      ```
      kubectl -n primehub get secret gitlab-registry -o jsonpath='{.data.\.dockerconfigjson}' | base64 --decode | jq .
      ```

  2. Add the helm override yaml.

      Old sample (admin-ui.yaml):

      ```yaml
      primehub:
        keycloakUrl: https://id.example.com/auth
        adminLocale: en
        adminUrl: https://example.com/admin
        appPrefix: /admin
        crdNamespace: hub
      ```

      Should migrate to new one (primehub-console.yaml):

      ```yaml
      keycloak:
        url: https://id.example.com/auth

      ui:
        locale: en
        url: https://example.com/admin
        appPrefix: /admin

      graphql:
        crdNamespace: hub
      ```

      Before install primehub-console, you should remove old admin-ui release:

      ```
      helm del --purge admin-ui
      ```

- [Optional] User portal page
  1. `PRIMEHUB_FEAURE_USER_PORTAL=true` will enable universal landing page for PrimeHub users.
  2. You can setup items link and welcome messages on landing page in primhub-console.yaml:
  ```yaml
  ...
  ui:
    ...
    portalConfig: |
      services:
        - name: Google
          uri: "https://www.google.com"
          image: "https://www.google.com.tw/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png"
        - name: GitLab
          uri: "https://gitlab.com"
          image: "https://shiring.github.io/tutorials/2017/09/04/GitLab_logo.png"
        - name: JupyterHub
          uri: "https://hub.aaron.dev.primehub.io"
          image: "https://cdn-images-1.medium.com/max/2400/1*m87_Htb_9Pstq0UcvNJ49w.png"
        - name: Admin Dashboard
          uri: "/cms"
          adminOnly: true
          image: "https://raw.githubusercontent.com/InfuseAI/primehub/master/docs/media/logo.png"
        - name: Maintenance Notebook
          uri: "/maintenance"
          adminOnly: true
          image: "https://raw.githubusercontent.com/InfuseAI/primehub/master/docs/media/logo.png"
      welcomeMessage: >
        <h1>Getting Started</h1>
        <div>End of Lines</div>
  ```

- [Optional] Migrate to unified domain name

  1. Add `PRIMEHUB_FEATURE_USER_PORTAL=true`, `PRIMEHUB_DOMAIN=` and `PRIMEHUB_SCHEME=` to `.env`.
  2. Add new [Valid Redirect URIs](https://www.keycloak.org/docs/6.0/server_admin/index.html#oidc-clients) to all affected keycloak clients. (e.g. `admin-ui`, `jupyterhub`, `maintenance-proxy`)
  3. For more information, please see [docs/design/user-portal.md](docs/design/user-portal.md)

## v1.6.2

 - Feature flag to support old convention for group volume [ch1257]
 - Support extra pod and node affinity [ch2667]
 - Upgrade admin-ui to v2.12.5
   - Fixed bug: Attributes in everyone group is removed after editing "Default User Volume Capacity" [ch3007]

### Deprecated

- To keep using legacy project group naming convention, do NOT run `modules/upgrade/optional/kc_group_volume_migration.sh` and need to add `SUPPORT_OLD_GROUP_VOLUME_CONVENTION=true` to your env file. This flag will be applied when you upgrade hub.


## v1.6.0

 - Fixed Bug: metacontroller primehub-group nfs pvc deletion (reproduce) [ch378]
 - Fixed cpu limits configured in group quota are not effective [ch423]
 - Fixed User can't spawn pod because volume manager try to chown everything [ch728]
 - Implement the single upgrade script for PrimeHub [ch294]
 - JupyterLab 404 message patch [ch341]
 - Group volume size & options [ch361]
 - Support Image Pull Secret for Images [ch362]
 - Users in everyone group has no quota by default [ch497]
 - Helm chart for maintenance notebook environment. [ch557]
 - Upgrade nginx-ingress chart to 1.6.16 and increase client-header-buffer-size to 16k [ch708]
 - Implement dataset `launchGroupOnly` in JupyterHub spawner [ch710]
 - Support Maintenance notebook feature. [ch711]
 - Patch rke nginx-ingress configMap [ch713]
 - nvidia-gpu-device-plugin has too small memory limit [ch419]

### Action Required

- In order to make [primehub-admin-notebook](https://github.com/infuseai/primehub-admin-notebook) to work properly,
  You'll have to increase the `client_header_buffer_size` of your nginx-ingress up to `16k`.
  (See `modules/charts/nginx-ingress.yaml` for example.).

  For rke, this change need patch nginx-ingress config map, please run the following command:

  ```
  kubectl -n ingress-nginx patch cm nginx-configuration --type merge -p '{"data":{"client-header-buffer-size":"16k"}}'
  ```

- The system group (`everyone`) now has resource limit by default. In previous version, everyone group has unlimited resource limits. They are now set to `0` by default. If you want to adopt this behavior when upgrading, please source your env file and run `modules/upgrade/optional/kc_everyone_group_default_limit.sh` to apply.

- Groups now have options to enable shared volume (project group) and set volume capacity on Admin UI. In previous version, project groups depend on naming convention that group name starts with `Project-`. To migrate existing project groups to new ones with options, please source your env file and run `modules/upgrade/optional/kc_group_volume_migration.sh`. The migration script will rename existing project groups to remove the prefix `Project-`, so please check if there is any group name conflict by running `modules/upgrade/optional/kc_check_group_names_conflict.sh`.

- Dataset now has option `Launch Group Only` and will display `Mount Root` on Admin UI. To migrate existing datasets, please run `modules/upgrade/optional/add_mount_root_to_datasets.sh`.

### Deprecated

- Project group naming convention is deprecated. Use group options to enable shared volume instead of naming group starts with `Project-`.

---
## v1.5.0

- Minimum autoscaling support [[ch73](https://app.clubhouse.io/infuseai/story/73)]
- map keycloak superuser role to jupyterhub admin [[ch65](https://app.clubhouse.io/infuseai/story/65)]
- Improve JupyterLab UX on reconnect and server stop [[ch42](https://app.clubhouse.io/infuseai/story/42)]
- Reorg kubectl plugins [[ch130](https://app.clubhouse.io/infuseai/story/130)]
- Script to create/delete keycloak user for hub load testing [[ch169](https://app.clubhouse.io/infuseai/story/169)]
- Implement the single upgrade script for PrimeHub [[ch294](https://app.clubhouse.io/infuseai/story/294)]
- Planning for cuda10/nvidia410 and tf-2.0 tests [[ch70](https://app.clubhouse.io/infuseai/story/70)]  [!302](https://gitlab.com/infuseai/primehub/merge_requests/302)
- Adjust default JupyterPageSlow alert rules [[ch166](https://app.clubhouse.io/infuseai/story/166)] [!304](https://gitlab.com/infuseai/primehub/merge_requests/304)
- Setup stable demo environment for potential clients [[ch66](https://app.clubhouse.io/infuseai/story/66)]
- Replace minikube with KIND in CI [[ch68](https://app.clubhouse.io/infuseai/story/68)]
- Add unit test to our CI [[ch312](https://app.clubhouse.io/infuseai/story/312)]
- Basic auto deploy demo hub [[ch67](https://app.clubhouse.io/infuseai/story/67)]
- Setup g suite oauth <-> b.demo [[ch136](https://app.clubhouse.io/infuseai/story/136)]
- In hub config, singleuser.nodeSelector is not working [[ch145](https://app.clubhouse.io/infuseai/story/145)]
- Remove `Stop My Server` button in control panel after server stopped [[ch259](https://app.clubhouse.io/infuseai/story/259)]
- JupyterLab UI is not rendering properly on JupyterHub 1.0 [[ch128](https://app.clubhouse.io/infuseai/story/128)]
- Group name should not be editable. bump admin-ui to v2.8.2 [!294](https://gitlab.com/infuseai/primehub/merge_requests/294) [canner-admin-ui#104](https://gitlab.com/infuseai/canner-admin-ui/issues/104)

### Action Required

1. After install helm-managed, also run the upgrade
`make primehub-upgrade`
2. To use the kubectl plugins, set the `$PRIMEHUB_HOME/bin` in the PATH environment variables or copy binaries inside to where the env `$PATH` can resolve it. Here are the kubectl plugins provided

        # shortcut to run ceph command
        kubectl ceph
        # shortcut to run rbd command
        kubectl rbd
        # wrapper of kubectl scale
        kubectl stasis
        # force delete
        kubectl fdelete

3. The nvidia memory limit changes. Please increase memory for nvidia device plugin

        kubectl apply -f modules/nvidia/device-plugin/nvidia-device-plugin.yaml

---
## v1.4.0

- Adjust group user volume capacity logic (min -> max) #457
- Fix the Gitlab CI to upgrade the kubernetes version #456
- Modify monitoring script for check_node_cordoned not always throw alert #455
- Limit user process and other resources that might be harmful to node #454
- Show primehub version in hub launch page #453
- Initial PrimeHub chart phase1 #452
- The docker registry should not be stored at the tmp folder #451
- Add merge request template #449
- KC password cannot be a number #448
- Cpu limit issue on demo hub #447
- [CVE-2019-9946] Upgrade kubernetes to 1.12.7 #446
- [CVE-2019-10255] Upgrade JupyterHub to 0.9.6 #445
- [CVE-2019-1002101] Upgrade kubectl binary to 1.12.7 #444
- Full cluster shutdown script for rook 0.9 #443
- Unifying user volume capacity keys #441
- Full cluster shutdown for rook 0.9.x #440
- Reorg kubectl plugins #439
- Rsync script for gitsync operation #430

---
## v1.3.0
Al hail Himalaya!

- Set TZ env for user notebook #396
- Make sure group volume works when default storage class is set #170 stage/qa
- Install Tensorboard-enabled image to Demo Hub #259
- Grafana dashboard for jupyterhub #271
- Backup script for group volume #346
- [CVE-2019-1002101] Upgrade kubetctl binary to 1.12.7 #444
- Failed to install nvidia-driver in airgap #429
- User quota bug in admin UI #194
- Make disable_cfs_quota as default in kubelet #433
- Improve keycloak backup/restore #395
- Ceph metadata device on VG #401
- Set rook-block sc default reclaim policy to Retain #432
- Don't override the image in helm value for non-airgapped setting #417
- Cleanup for modules/support #416
- Fix dev-gce Makefile for new installer #414
- Ensure dev-gce install in airgap #406
- Automate dev-gce airgap environment setup #403
- Install Tensorboard-enabled image to Demo Hub #259
- Remove public keys from repo #415

### Action Required

- Migratie Keycloak client jupyterhub mapper by running the migration script

        ./modules/bootstrap/kc_migration.sh

- Migrate group volume nfs metacontroller

        ./modules/primehub-groupvolume-nfs/upgrade.sh

- upgrade kubectl to 1.12.7. copy `./bin/kubectl` to $PATH
- upgrade k8s to 1.12.7. Please following the steps
    1. edit rke configuration file `cluster.yml`
    2. Add a `system_images.kubernetes` to ` rancher/hyperkube:v1.12.7-rancher1` and don't change the `kubernetes_version`

            kubernetes_version: v1.12.4-rancher1-1    <--- leave v1.12.4. This is used for rke
            system_images:
              etcd: rancher/coreos-etcd:v3.2.24
              kubernetes: rancher/hyperkube:v1.12.7-rancher1    <-----
              alpine: rancher/rke-tools:v0.1.16
              nginx_proxy: rancher/rke-tools:v0.1.16

    3. do the `rke up`


---
## v1.2.0

- Group volume (metacontroller) does not work in dev-gce [#383](https://gitlab.com/infuseai/primehub/issues/383) type/bug
- HOWTO document for add/remove nodes and change the controlplane node [#382](https://gitlab.com/infuseai/primehub/issues/382)
- EFK should only save hub & jupyter logs with log level ≥ warning [#378](https://gitlab.com/infuseai/primehub/issues/378)
- Dataset refresh should not require restarting server [#354](https://gitlab.com/infuseai/primehub/issues/354) type/bug
- Upgrade rook 0.9.1 [#344](https://gitlab.com/infuseai/primehub/issues/344)
- Test rook bluestore layout for mixed devices [#316](https://gitlab.com/infuseai/primehub/issues/316)
- Survey how to remove a ceph node from cluster [#386](https://gitlab.com/infuseai/primehub/issues/386)
- Upgrade docker for security [#404](https://gitlab.com/infuseai/primehub/issues/404)
- Airgap image push script should stripe shasum [#405](https://gitlab.com/infuseai/primehub/issues/405)
- Dev-gce one command setup script [#399](https://gitlab.com/infuseai/primehub/issues/399)
- Full shutdown/restart script [#361](https://gitlab.com/infuseai/primehub/issues/361)
- Remove ansible templates from ansible "release builder" role [#319](https://gitlab.com/infuseai/primehub/issues/319)
- Refine helmfile process for downloaded charts in airgapped mode [#297](https://gitlab.com/infuseai/primehub/issues/297)
- Per-node upgrade helper [#250](https://gitlab.com/infuseai/primehub/issues/250)
- Survey how to add/remove/manage etcd by rke [#385](https://gitlab.com/infuseai/primehub/issues/385)

---

## v1.1.0

- Jupyter-notebook setup have pip timeout issue when enable network policy [#392](https://gitlab.com/infuseai/primehub/issues/392)
- Upgrade kibana to 6.5.1 [#391](https://gitlab.com/infuseai/primehub/issues/391)
- Tensorboard start-notebook-d conflict with network policy [#390](https://gitlab.com/infuseai/primehub/issues/390)
- Remove not being referenced anymore files in installer/skeleton/ [#388](https://gitlab.com/infuseai/primehub/issues/388)
- Allow multiple login actions for newly created users [#384](https://gitlab.com/infuseai/primehub/issues/384)
- Lock EFK chart version [#371](https://gitlab.com/infuseai/primehub/issues/371)
- Add `make install-required-ansible-roles` back [#366](https://gitlab.com/infuseai/primehub/issues/366)
- Prometheus-node-exporter does not have resources requests/limits [#353](https://gitlab.com/infuseai/primehub/issues/353)
- Investigate better way to do nvidia.com/gpu: 0 [#352](https://gitlab.com/infuseai/primehub/issues/352)
- Default nodeSelector for fluentd [#349](https://gitlab.com/infuseai/primehub/issues/349)
- Fixed tensorboard serverextension is not correctly set up. [#339](https://gitlab.com/infuseai/primehub/issues/339)
- Correct namespace of primehub-groupvolume-nfs [#338](https://gitlab.com/infuseai/primehub/issues/338)
- Test upgrade path to kubernetes 1.12 [#335](https://gitlab.com/infuseai/primehub/issues/335)
- Show GPU utilization information from dashboard [#318](https://gitlab.com/infuseai/primehub/issues/318)
- Improve pod-level OOM behaviour [#317](https://gitlab.com/infuseai/primehub/issues/317)
- Installer should use downloaded helm binary to pull the remote helm chart [#311](https://gitlab.com/infuseai/primehub/issues/311)
- Keycloak image not overridden with airgap [#310](https://gitlab.com/infuseai/primehub/issues/310)
- Lock prometheus chart version [#304](https://gitlab.com/infuseai/primehub/issues/304)
- Custom search for KeyCloak events in Kibana [#296](https://gitlab.com/infuseai/primehub/issues/296)
- Calico should only throw log with level >= warning [#295](https://gitlab.com/infuseai/primehub/issues/295)

---

## v1.0.0

- Update kubernetes to 1.10.11 for rke install. CVE-2018-1002105 (#300)
