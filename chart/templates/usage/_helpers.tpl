{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "primehub-usage.name" -}}
{{ include "primehub.name" . }}-usage
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "primehub-usage.fullname" -}}
{{ include "primehub.fullname" . }}-usage
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "primehub-usage.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "primehub-usage.labels" -}}
helm.sh/chart: {{ include "primehub-usage.chart" . }}
{{ include "primehub-usage.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "primehub-usage.selectorLabels" -}}
app.kubernetes.io/name: {{ include "primehub-usage.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "primehub-usage.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "primehub-usage.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{- define "primehub-usage.enabled" -}}
  {{- if (and .Values.usage.enabled) -}}
    true
  {{- else -}}
    false
  {{- end -}}
{{- end -}}
