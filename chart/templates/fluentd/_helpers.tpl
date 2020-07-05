{{- define "fluentd.enabled" -}}
  {{- if (and .Values.store.enabled .Values.store.logPersistence.enabled) -}}
    true
  {{- else -}}
    false
  {{- end -}}
{{- end -}}
