function(request) {
  local svc = request.object,
  local annotations = svc.metadata.annotations,
  local group = annotations["primehub-group"],
  local capacity = annotations["primehub-group-capacity"],
  local labels = {
    "primehub-group": group,
    "primehub-namespace": svc.metadata.namespace
  },
  local mount_options = if std.objectHas(annotations, "primehub-group-mount-options")
    then annotations["primehub-group-mount-options"]
    else "nfsvers=4.1",

  attachments: [
    {
      apiVersion: "v1",
      kind: "PersistentVolume",
      metadata: {
        name: svc.metadata.namespace + "-" + svc.metadata.name,
        labels: labels,
      },
      spec: {
        selector: labels,
        accessModes: ["ReadWriteMany"],
        capacity: { storage: capacity },
        mountOptions: std.split(mount_options, ","),
        nfs: {
          server: svc.spec.clusterIP,
          path: "/"
        }
      },
    }
  ]
}
