{{/* vim: set filetype=mustache: */}}
{{/*
Global
*/}}
{{- define "primehub.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "primehub.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "primehub.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "primehub.url" -}}
{{- if .Values.primehub.port -}}
{{- printf "%s://%s:%v" .Values.primehub.scheme .Values.primehub.domain .Values.primehub.port }}
{{- else -}}
{{- printf "%s://%s" .Values.primehub.scheme .Values.primehub.domain }}
{{- end -}}
{{- end -}}

{{/*
Keycloak
*/}}
{{- define "primehub.keycloak.url" -}}
{{- if .Values.keycloak.deploy -}}
{{- printf "%s/auth" (include "primehub.url" .) }}
{{- else }}
{{- if .Values.primehub.keycloak.port -}}
{{- printf "%s://%s:%v/auth" .Values.primehub.keycloak.scheme (include "primehub.keycloak.domain" .) .Values.primehub.keycloak.port }}
{{- else -}}
{{- printf "%s://%s/auth" .Values.primehub.keycloak.scheme (include "primehub.keycloak.domain" .) }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "primehub.keycloak.domain" -}}
{{- if .Values.keycloak.deploy -}}
{{- printf "%s" .Values.primehub.domain }}
{{- else -}}
{{- printf "%s" .Values.primehub.keycloak.domain }}
{{- end -}}
{{- end -}}

{{- define "primehub.keycloak.username" -}}
{{- if .Values.keycloak.deploy -}}
{{- .Values.keycloak.username }}
{{- else -}}
{{- .Values.primehub.keycloak.username }}
{{- end -}}
{{- end -}}

{{- define "primehub.keycloak.password" -}}
{{- if .Values.keycloak.deploy -}}
{{- .Values.keycloak.password }}
{{- else -}}
{{- .Values.primehub.keycloak.password }}
{{- end -}}
{{- end -}}

{{/*
Console
*/}}
{{- define "primehub.console.path" -}}/console{{- end -}}
{{- define "primehub.console.url" -}}
{{- printf "%s%s" (include "primehub.url" .) (include "primehub.console.path" .) -}}
{{- end -}}
{{- define "primehub.console.clientId" -}}{{.Values.primehub.keycloak.clientId}}{{- end -}}
{{- define "primehub.console.redirectUri" -}}{{- printf "%s/*" (include "primehub.console.url" .) -}}{{- end -}}
{{- define "primehub.console.pullSecret" -}}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .Values.console.image.credentials.registry (printf "%s:%s" .Values.console.image.credentials.username .Values.console.image.credentials.password | b64enc) | b64enc -}}
{{- end -}}

{{/*
Graphql
*/}}
{{- define "primehub.graphql.path" -}}/api{{- end -}}
{{- define "primehub.graphql.endpoint" -}}
{{- printf "%s%s%s" (include "primehub.url" .) (include "primehub.graphql.path" .) "/graphql" -}}
{{- end -}}
{{- define "primehub.graphql.pullSecret" -}}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .Values.graphql.image.credentials.registry (printf "%s:%s" .Values.graphql.image.credentials.username .Values.graphql.image.credentials.password | b64enc) | b64enc -}}
{{- end -}}


{{/*
Watcher
*/}}
{{- define "primehub.watcher.pullSecret" -}}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .Values.watcher.image.credentials.registry (printf "%s:%s" .Values.watcher.image.credentials.username .Values.watcher.image.credentials.password | b64enc) | b64enc -}}
{{- end -}}


{{/*
Jupyterhub
*/}}
{{- define "primehub.jupyterhub.path" -}}/console{{- end -}}
{{- define "primehub.jupyterhub.clientId" -}}{{ .Values.jupyterhub.primehub.keycloakClientId }}{{- end -}}
{{- define "primehub.jupyterhub.redirectUri" -}}{{- printf "%s/*" (include "primehub.url" .) -}}{{- end -}}

{{/*
Custom Image
*/}}
{{- define "primehub.customImage.pushSecret" -}}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .Values.customImage.registryEndpoint (printf "%s:%s" .Values.customImage.registryUsername .Values.customImage.registryPassword | b64enc) | b64enc -}}
{{- end -}}

{{/*
Admin Notebook
*/}}
{{- define "primehub.adminNotebook.path" -}}/maintenance{{- end -}}
{{- define "primehub.adminNotebook.url" -}}
{{- printf "%s%s" (include "primehub.url" .) (include "primehub.adminNotebook.path" .) -}}
{{- end -}}
{{- define "primehub.adminNotebook.clientId" -}}maintenance-proxy{{- end -}}
{{- define "primehub.adminNotebook.redirectUri" -}}{{- printf "%s/*" (include "primehub.adminNotebook.url" .) -}}{{- end -}}

{{/*
Dataset
*/}}
{{- define "primehub.dataset.path" -}}/dataset{{- end -}}
{{- define "primehub.dataset.url" -}}
{{- printf "%s%s" (include "primehub.url" .) (include "primehub.dataset.path" .) -}}
{{- end -}}


{{/*
Store
*/}}
{{- define "primehub.phfs.enabled" -}}
  {{- if (and .Values.store.enabled .Values.store.phfs.enabled) -}}
    true
  {{- else -}}
    false
  {{- end -}}
{{- end -}}

{{- define "primehub.feature.logPersistence.enabled" -}}
  {{- if (and .Values.store.enabled .Values.store.logPersistence.enabled) -}}
    true
  {{- else -}}
    false
  {{- end -}}
{{- end -}}


{{- define "primehub.store.endpoint" -}}
  http://{{ include "primehub.fullname" . }}-minio.{{ .Release.Namespace}}:{{ .Values.minio.service.port }}
{{- end -}}
{{- define "primehub.store.bucket" -}}
  {{.Values.store.bucket}}
{{- end -}}
{{- define "primehub.store.accessKey" -}}
  {{.Values.store.accessKey}}
{{- end -}}
{{- define "primehub.store.secretKey" -}}
  {{.Values.store.secretKey}}
{{- end -}}
{{- define "primehub.store.pvcName" -}}
  {{include "primehub.name" .}}-store
{{- end -}}

{{/*
Keycloak
*/}}
{{- define "keycloak.name" -}}
{{- "keycloak" -}}
{{- end -}}

{{- define "keycloak.fullname" -}}
{{- "keycloak" -}}
{{- end -}}

{{/*
Create the service DNS name.
*/}}
{{- define "keycloak.serviceDnsName" -}}
{{ include "keycloak.fullname" . }}-headless.{{ .Release.Namespace }}.svc.{{ .Values.keycloak.clusterDomain }}
{{- end -}}

{{/*
{{/*
Create common labels.
*/}}
{{- define "keycloak.commonLabels" -}}
app.kubernetes.io/name: {{ include "keycloak.name" . }}
helm.sh/chart: {{ include "primehub.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Create selector labels.
*/}}
{{- define "keycloak.selectorLabels" -}}
app.kubernetes.io/name: {{ include "keycloak.name" . }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- end -}}

{{/*
Create name of the service account to use
*/}}
{{- define "keycloak.serviceAccountName" -}}
{{- if .Values.keycloak.serviceAccount.create -}}
    {{ default (include "keycloak.fullname" .) .Values.keycloak.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.keycloak.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name for the postgres requirement.
*/}}
{{- define "keycloak.postgresql.fullname" -}}
{{- $postgresContext := dict "Values" .Values.keycloak.postgresql "Release" .Release "Chart" (dict "Name" "postgresql") -}}
{{ include "postgresql.fullname" $postgresContext }}
{{- end -}}

{{/*
Create the name for the Keycloak secret.
*/}}
{{- define "keycloak.secret" -}}
{{- if .Values.keycloak.existingSecret -}}
  {{- tpl .Values.keycloak.existingSecret $ -}}
{{- else -}}
  {{- include "keycloak.fullname" . -}}-http
{{- end -}}
{{- end -}}

{{/*
Create the name for the database secret.
*/}}
{{- define "keycloak.dbSecretName" -}}
{{- if .Values.keycloak.persistence.existingSecret -}}
  {{- tpl .Values.keycloak.persistence.existingSecret $ -}}
{{- else -}}
  {{- include "keycloak.fullname" . -}}-db
{{- end -}}
{{- end -}}

{{/*
Create the Keycloak password.
*/}}
{{- define "keycloak.password" -}}
{{- if .Values.keycloak.password -}}
  {{- .Values.keycloak.password | b64enc | quote -}}
{{- else -}}
  {{- randAlphaNum 16 | b64enc | quote -}}
{{- end -}}
{{- end -}}

{{/*
Create the name for the password secret key.
*/}}
{{- define "keycloak.passwordKey" -}}
{{- if .Values.keycloak.existingSecret -}}
  {{- .Values.keycloak.existingSecretKey -}}
{{- else -}}
  password
{{- end -}}
{{- end -}}

{{/*
Create the name for the database password secret key.
*/}}
{{- define "keycloak.dbPasswordKey" -}}
{{- if and .Values.keycloak.persistence.existingSecret .Values.keycloak.persistence.existingSecretPasswordKey -}}
  {{- .Values.keycloak.persistence.existingSecretPasswordKey -}}
{{- else -}}
  password
{{- end -}}
{{- end -}}

{{/*
Create the name for the database password secret key - if it is defined.
*/}}
{{- define "keycloak.dbUserKey" -}}
{{- if and .Values.keycloak.persistence.existingSecret .Values.keycloak.persistence.existingSecretUsernameKey -}}
  {{- .Values.keycloak.persistence.existingSecretUsernameKey -}}
{{- else -}}
  username
{{- end -}}
{{- end -}}

{{/*
Create environment variables for database configuration.
*/}}
{{- define "keycloak.dbEnvVars" -}}
{{- if .Values.keycloak.persistence.deployPostgres }}
{{- if not (eq "postgres" .Values.keycloak.persistence.dbVendor) }}
{{ fail (printf "ERROR: 'Setting keycloak.persistence.deployPostgres' to 'true' requires setting 'keycloak.persistence.dbVendor' to 'postgres' (is: '%s')!" .Values.keycloak.persistence.dbVendor) }}
{{- end }}
- name: DB_VENDOR
  value: postgres
- name: DB_ADDR
  value: {{ include "keycloak.postgresql.fullname" . }}
- name: DB_PORT
  value: "5432"
- name: DB_DATABASE
  value: {{ .Values.keycloak.postgresql.postgresqlDatabase | quote }}
- name: DB_USER
  value: {{ .Values.keycloak.postgresql.postgresqlUsername | quote }}
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "keycloak.postgresql.fullname" . }}
      key: postgresql-password
{{- else }}
- name: DB_VENDOR
  value: {{ .Values.keycloak.persistence.dbVendor | quote }}
{{- if not (eq "h2" .Values.keycloak.persistence.dbVendor) }}
- name: DB_ADDR
  value: {{ .Values.keycloak.persistence.dbHost | quote }}
- name: DB_PORT
  value: {{ .Values.keycloak.persistence.dbPort | quote }}
- name: DB_DATABASE
  value: {{ .Values.keycloak.persistence.dbName | quote }}
- name: DB_USER
  valueFrom:
    secretKeyRef:
      name: {{ include "keycloak.dbSecretName" . }}
      key: {{ include "keycloak.dbUserKey" . | quote }}
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "keycloak.dbSecretName" . }}
      key: {{ include "keycloak.dbPasswordKey" . | quote }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Create the namespace for the serviceMonitor deployment.
*/}}
{{- define "keycloak.serviceMonitor.namespace" -}}
{{- if .Values.keycloak.prometheus.operator.serviceMonitor.namespace -}}
{{ .Values.keycloak.prometheus.operator.serviceMonitor.namespace }}
{{- else -}}
{{ .Release.Namespace }}
{{- end -}}
{{- end -}}
