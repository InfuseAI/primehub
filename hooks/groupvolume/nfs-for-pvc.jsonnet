function(request) {
  local pvc = request.object,
  local annotations = pvc.metadata.annotations,
  local group = annotations["primehub-group"],
  local rwo_sc = if std.objectHas(annotations, "primehub-group-sc")
    then annotations["primehub-group-sc"]
    else "rook-block",
  local mount_options = if std.objectHas(annotations, "primehub-group-mount-options")
    then annotations["primehub-group-mount-options"]
    else "nfsvers=4.1",

  // Create a nfs rc, service, and pv
  selector: {
    matchLabels: {
      "primehub-group": group,
      "primehub-namespace": pvc.metadata.namespace
    }
  },
  attachments: [
    {
      apiVersion: "v1",
      kind: "Service",
      metadata: {
        name: "nfs-" + pvc.metadata.name,
        annotations: {
          "primehub-group": pvc.metadata.annotations["primehub-group"],
          "primehub-group-mount-options": mount_options,
          "primehub-group-capacity": pvc.spec.resources.requests.storage
        }
      },
      spec: {
        selector: {
          role: "nfs-server",
          app: "primehub-group",
          "primehub-group": group,
        },
        ports: [
          { name: "nfs", port: 2049 },
          { name: "mountd", port: 20048 },
          { name: "rpcbind", port: 111 },
        ]
      },
    },
    {
      apiVersion: "apps/v1",
      kind: "StatefulSet",
      metadata: {
        name: "nfs-" + pvc.metadata.name,
        labels: {
          "role": "nfs-server",
          "app": "primehub-group",
          "primehub-group": pvc.metadata.name,
        },
      },
      spec: {
        replicas: 1,
        serviceName: "nfs-server",
        selector: {
          matchLabels: {
            "role": "nfs-server",
            "app": "primehub-group",
            "primehub-group": group
          },
        },
        template: {
          metadata: {
            labels: {
              "role": "nfs-server",
              "app": "primehub-group",
              "primehub-group": group}
          },
          spec: {
            affinity: {
              podAntiAffinity: {
                preferredDuringSchedulingIgnoredDuringExecution: [
                  {
                    weight: 1,
                    podAffinityTerm: {
                      topologyKey: "kubernetes.io/hostname",
                      labelSelector: {
                        matchExpressions: [
                          {
                            key: "role",
                            operator: "In",
                            values: ["nfs-server"],
                          },
                        ],
                      },
                    },
                  },
                ],
              },
            },
            terminationGracePeriodSeconds: 30,
            containers: [ {
              name: "nfs-server",
              image: "{{ .Values.groupvolume.nfs.image.repository }}:{{ .Values.groupvolume.nfs.image.tag }}",
              imagePullPolicy: "{{ .Values.groupvolume.nfs.image.pullPolicy }}",
              ports: [
                { name: "nfs", containerPort: 2049 },
                { name: "mountd", containerPort: 20048 },
                { name: "rpcbind", containerPort: 111 },
              ],
              securityContext: { privileged: true },
              resources: {
                limits: {
                  cpu: "50m",
                  memory: "256Mi",
                }
              },
              volumeMounts: [
                { mountPath: "/exports", name: "data" }
              ]
            } ]
          }
        },
        volumeClaimTemplates: [
          {
            metadata: {
              name: "data"
            },
            spec: {
              accessModes: [ "ReadWriteOnce" ],
              storageClassName: rwo_sc,
              resources: pvc.spec.resources
            }
          }
        ]
      }
    }
  ]
}
