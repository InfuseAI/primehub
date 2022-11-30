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

{{- define "primehub.keycloak.appUrl" -}}
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

{{- define "primehub.keycloak.url" -}}
{{- if .Values.keycloak.deploy -}}
{{- printf "http://keycloak-http.%s/auth" .Release.Namespace}}
{{- else if .Values.primehub.keycloak.svcUrl -}}
{{- .Values.primehub.keycloak.svcUrl }}
{{- else -}}
{{ include "primehub.keycloak.appUrl" . }}
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
{{- define "primehub.graphql.url" -}}
{{- printf "%s%s" (include "primehub.url" .) (include "primehub.graphql.path" .) -}}
{{- end -}}
{{- define "primehub.graphql.endpoint" -}}
http://{{ include "primehub.name" . }}-graphql{{include "primehub.graphql.path" .}}/graphql
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
  {{/* log persistence is only used in job submission. Only avaiable in ee. */}}
  {{- if (and (eq .Values.primehub.mode "ee") .Values.store.enabled .Values.store.logPersistence.enabled) -}}
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
ssh bastion server
*/}}
{{- define "ssh-bastion-server.name" -}}
{{- "ssh-bastion-server" -}}
{{- end -}}

{{- define "ssh-bastion-server.labels" -}}
helm.sh/chart: {{ include "primehub.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "ssh-bastion-server.ssh.target.labels" -}}
{{- $v := "" }}
{{- range $key, $value := .Values.sshBastionServer.ssh.target.matchLabels }}
{{- $v = printf "%s,%s" $v (printf "%s=%v" $key $value) }}
{{- end }}
{{- printf "%v" $v | trimPrefix "," }}
{{- end }}

{{/*
primehub usage
*/}}
{{- define "primehub-usage.name" -}}
{{ include "primehub.name" . }}-usage
{{- end }}

{{- define "primehub-usage.api" -}}
{{- printf "http://%s%s" (include "primehub-usage.name" .) "-api" -}}
{{- end }}

{{- define "primehub-usage.enabled" -}}
  {{- if or (eq .Values.primehub.mode "ee") (eq .Values.primehub.mode "deploy") -}}
  {{- if (and .Values.usage.enabled) -}}
    true
  {{- else -}}
    false
  {{- end -}}
  {{- else -}}
    false
  {{- end -}}
{{- end -}}


{{/*
primehub deployment
*/}}
{{- define "primehub-deployment.enabled" -}}
  {{- if and (eq .Values.primehub.mode "ee") .Values.modelDeployment.enabled -}}
    true
  {{- else if eq .Values.primehub.mode "deploy" -}}
    true
  {{- else -}}
    false
  {{- end -}}
{{- end -}}

{{/*
primehub admission
*/}}
{{- define "primehub-admission.webhook-certs.manage" -}}
{{- $data := (dict "cacert" "" "cert" "" "key" "") }}
{{- $secretData := (lookup "v1" "Secret" .Release.Namespace "primehub-admission-webhook-certs").data -}}
{{- if $secretData }}
  {{- if hasKey $secretData "cert.pem" }}
    {{- $_ := set $data "cert" (index $secretData "cert.pem" | quote) }}
  {{- end -}}
  {{- if hasKey $secretData "key.pem" }}
    {{- $_ := set $data "key" (index $secretData "key.pem" | quote) }}
  {{- end -}}
  {{- if hasKey $secretData "cacert.pem" }}
    {{- $_ := set $data "cacert" (index $secretData "cacert.pem" | quote) }}
  {{- end -}}
{{- else }}
  {{- $ca := genCA "primehub-admission-webhook-certs" 3650 }}
  {{- $_ := set $data "cacert" ($ca.Cert | b64enc | quote) }}
  {{- $cn := "primehub-admission" }}
  {{- $altName1 := printf "%s.%s" $cn .Release.Namespace }}
  {{- $altName2 := printf "%s.%s.svc" $cn .Release.Namespace }}
  {{- $altNames := (list $altName1 $altName2) }}
  {{- $cert := genSignedCert $cn nil $altNames 3650 $ca }}
  {{- $_ := set $data "cert" ($cert.Cert | b64enc | quote) }}
  {{- $_ := set $data "key" ($cert.Key | b64enc | quote) }}
{{- end -}}
{{- $data | toYaml -}}
{{- end -}}
