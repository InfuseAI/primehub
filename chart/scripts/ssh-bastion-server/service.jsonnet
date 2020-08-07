function(request) {
  local pod = request.object,
  local pod_labels = pod.metadata.labels,
  local annotations = pod.metadata.annotations,
  local namespace = pod.metadata.namespace,
  local pod_name = pod.metadata.name,

  attachments: [
    {
      apiVersion: "v1",
      kind: "Service",
      metadata: {
        name: pod_name,
        namespace: namespace
      },
      spec: {
        selector: pod_labels,
        ports: [
          {
            name: "ssh",
            port: 22,
            protocol: "TCP",
            targetPort: 22,
          },
        ],
        type: "ClusterIP"
      },
    },
  ],
}
