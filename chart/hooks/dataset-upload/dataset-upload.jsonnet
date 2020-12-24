function(request) {
  local dataset = request.object,
  local metadata = dataset.metadata,
  local resource_name = "dataset-upload-" + metadata.name,
  local dataset_type = dataset.spec.type,

  local primehub_dataset_upload_prefix = "{{include "primehub.dataset.path" .}}",
  local front_end_path = primehub_dataset_upload_prefix + "/" + metadata.namespace + "/" + metadata.name + "/browse",
  local tusd_path = primehub_dataset_upload_prefix + "/" + metadata.namespace + "/" + metadata.name + "/upload",

  local primehub_scheme = "{{.Values.primehub.scheme}}",
  local primehub_domain = "{{.Values.primehub.domain}}",
  local tls={{.Values.ingress.tls | toJson}},

  local mount_volume = if dataset_type == 'pv'
    then {
      name: "tus-volume",
      persistentVolumeClaim: {
        claimName: "dataset-" + metadata.name
      }
    }
    else if dataset_type == 'nfs'
      then {
        name: "tus-volume",
        nfs: {
          server: dataset.spec.nfs.server,
          path: dataset.spec.nfs.path
        },
      }
    else if dataset_type == 'hostPath'
      then {
        name: "tus-volume",
        hostPath: {
          path: dataset.spec.hostPath.path
        },
      }
    else {},
  local mount_hooks = {
    name: "tus-hooks",
    configMap: {
      name: "primehub-dataset-upload-hooks",
      // converted from octal 0755
      defaultMode: 493
    }
  },

  local deploy = {
    apiVersion: "apps/v1",
    kind: "Deployment",
    metadata: {
      name: resource_name,
      namespace: "{{ .Release.Namespace }}",
      labels: {
        app: resource_name,
      },
    },
    spec: {
      replicas: {{.Values.datasetUpload.interface.replicas}},
      selector: {
        matchLabels: {
          app: resource_name,
        },
      },
      template: {
        metadata: {
          labels: {
            app: resource_name,
          },
        },
        spec: {
          containers: [
            {
              name: "tusd",
              image: "{{.Values.tusd.image.repository}}:{{.Values.tusd.image.tag}}",
              ports: [
                {
                  "containerPort": 1080
                }
              ],
              imagePullPolicy: "{{.Values.tusd.image.pullPolicy}}",
              volumeMounts: [
                {
                    mountPath: "/srv/tusd-data/data",
                    name: "tus-volume"
                },
                {
                    mountPath: "/srv/tusd-hooks",
                    name: "tus-hooks"
                }
              ],
              command: ["tusd"],
              args: ["--hooks-dir","/srv/tusd-hooks","-base-path",tusd_path+"/files/","-metrics-path",tusd_path+"/metrics","-behind-proxy"],
              securityContext: {
                runAsUser: 0
              },
              resources: {{.Values.datasetUpload.interface.webFrontEndImage.resources|toJson}}
            },

            {
              name: "web-front-end",
              image: "{{.Values.datasetUpload.interface.webFrontEndImage.repository}}:{{.Values.datasetUpload.interface.webFrontEndImage.tag}}",
              ports: [
                {
                  "containerPort": 80
                }
              ],
              imagePullPolicy: "{{.Values.datasetUpload.interface.webFrontEndImage.pullPolicy}}",
              volumeMounts: [
                {
                    mountPath: "/srv/data",
                    name: "tus-volume"
                }
              ],
              env: [
                {
                  name: "PRIMEHUB_SCHEME",
                  value: primehub_scheme
                },
                {
                  name: "PRIMEHUB_DOMAIN",
                  value: primehub_domain
                },
                {
                  name: "FRONT_END_PATH",
                  value: front_end_path
                },
                {
                  name: "TUSD_PATH",
                  value: tusd_path
                },
              ],
              resources: {{.Values.datasetUpload.interface.tusd.resources|toJson}}
            },
          ],
          volumes: [
            mount_volume,
            mount_hooks
          ],
        },
      },
    },
  },

  local svc = {
    apiVersion: "v1",
    kind: "Service",
    metadata: {
      name: resource_name,
      namespace: "{{ .Release.Namespace }}",
      labels: {
        app: resource_name,
      },
    },
    spec: {
      selector: {
        app: resource_name,
      },
      ports: [
        { name: "tus", port: 1080, targetPort: 1080 },
        { name: "flask", port: 80, targetPort: 80 },
      ],
      sessionAffinity: "None",
      type: "ClusterIP"
    },
  },

  local ingress_anno = if std.objectHas(metadata, "annotations")
    then
      if std.objectHas(metadata.annotations, "dataset.primehub.io/uploadServerAuthSecretName")
        then {
          "nginx.ingress.kubernetes.io/proxy-body-size": "0m",
          "nginx.ingress.kubernetes.io/proxy-request-buffering": "off",
          "nginx.ingress.kubernetes.io/ssl-redirect": "false",
          "nginx.ingress.kubernetes.io/auth-type": "basic",
          "nginx.ingress.kubernetes.io/auth-secret": metadata.annotations["dataset.primehub.io/uploadServerAuthSecretName"],
          "nginx.ingress.kubernetes.io/auth-realm": "Authentication Required"
        }
        else {}
    else {},

  local ing = {
    apiVersion: "networking.k8s.io/v1beta1",
    kind: "Ingress",
    metadata: {
      name: resource_name,
      namespace: "{{ .Release.Namespace }}",
      annotations: {{.Values.ingress.annotations|toJson}} + ingress_anno,
      labels: {
        app: resource_name,
        component: "ingress"
      },
    },
    spec: {
      rules: [
        {
          host: primehub_domain,
          http: {
            paths: [
              {
                backend: {
                  serviceName: resource_name,
                  servicePort: 80
                },
                path: front_end_path
              },
              {
                backend: {
                  serviceName: resource_name,
                  servicePort: 1080
                },
                path: tusd_path
              }
            ]
          }
        }
      ],
      tls: tls
    },
  },

  local atts = if std.objectHas(metadata, "annotations")
    then
      if std.objectHas(metadata.annotations, "dataset.primehub.io/uploadServer")
        then
        if metadata.annotations['dataset.primehub.io/uploadServer'] == "true"
          then [deploy,svc,ing]
          else []
      else []
    else [],

  attachments: [
  ] + atts
}
