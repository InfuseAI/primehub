{{- define "rclone.enabled" -}}
  {{- if (and .Values.store.enabled .Values.store.phfs.enabled) -}}
    true
  {{- else -}}
    false
  {{- end -}}
{{- end -}}

{{- define "rclone.kubeletPath" -}}
  {{- if .Values.rclone.kubeletPath -}}
    {{ .Values.rclone.kubeletPath }}
  {{- else -}}
    /var/lib/kubelet
  {{- end -}}
{{- end -}}
