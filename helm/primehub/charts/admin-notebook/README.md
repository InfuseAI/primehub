
## Introduction

The helm chart of [primehub-admin-notebook](https://github.com/InfuseAI/primehub-admin-notebook). 

This chart also integrates with [keycloak-gateway](https://www.keycloak.org/docs/4.8/securing_apps/index.html#_keycloak_generic_adapter) to secure this application.

## Configuration
The following table lists the configurable parameters of the PrimeHub chart and their default values.

Parameter | Description | Default
--- | --- | ---
`replicaCount` |  | `1`
`image.*` | The keycloak realm for primehub |  `primehub`
`nameOverride` | App name | `""`
`fullnameOverride`|Fully qualified app name  | `""`
`baseUrl`| The base url of admin notebook | `/maintenance`  
`resources`| The resource definition of admin-notebook container | `{}`
`proxy.enabled`| If enable the keycloak-gateway proxy. | `true`
`proxy.enableRefreshToken`| If refresh token enabled | `false`
`proxy.encryptionKey`| If enacryption key enabled. | `ffffffffffffffffffffffffffffffff`
`proxy.verbose`| If verbose or not | `false`
`proxy.resources`| The resource difinition of keycloak-gateway container | `{}`
`nodeSelector`| Node selector settings for admin-notebook pod | `{}`
`tolerations`| Toleration settings for admin-notebook pod  |`[]`
`affinity`| Affinity settings for admin-notebook pod  | `{}`
`service.*`| Kuberentes service settings for this admin-notebook  |
`ingress.*`| Kuberentes ingress settings for this admin-notebook  |
