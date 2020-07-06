{{- define "rclone.enabled" -}}
  {{- if (and .Values.store.enabled .Values.store.phfs.enabled) -}}
    true
  {{- else -}}
    false
  {{- end -}}
{{- end -}}
