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
{{- if .Values.primehub.keycloak.port -}}
{{- printf "%s://%s:%v/auth" .Values.primehub.keycloak.scheme .Values.primehub.keycloak.domain .Values.primehub.keycloak.port }}
{{- else -}}
{{- printf "%s://%s/auth" .Values.primehub.keycloak.scheme .Values.primehub.keycloak.domain }}
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
  {{.Values.minio.accessKey}}
{{- end -}}
{{- define "primehub.store.secretKey" -}}
  {{.Values.minio.secretKey}}
{{- end -}}
{{- define "primehub.store.pvcName" -}}
  {{include "primehub.name" .}}-store
{{- end -}}
