function(request) {
  local ds = request.object,
  local is_gittype = ds.spec.type == "git",

  local gitsync = if std.objectHas(ds.spec, 'gitsync') then ds.spec.gitsync else {},
  local annotations = if std.objectHas(ds.metadata, 'annotations') then ds.metadata.annotations else {},

  local use_secret = std.objectHas(gitsync, 'secret'),
  local secret = if use_secret then gitsync.secret else "",

  # set default value
  local hostPath = if std.objectHas(annotations, 'dataset.primehub.io/gitSyncHostRoot') then annotations['dataset.primehub.io/gitSyncHostRoot'] else '/home/dataset',
  local wait = "600",

  # split repo url and branch
  local splited = std.splitLimit(ds.spec.url, "#", 1),
  local length = std.length(splited),
  local branch = if length > 1 then splited[length - 1] else "master",
  local orig_url = if length > 1 then splited[0] else ds.spec.url,
  local url = if std.endsWith(orig_url, '.git') then orig_url else orig_url + '.git',

  attachments: if is_gittype then [
    {
      apiVersion: "apps/v1",
      kind: "DaemonSet",
      metadata: {
        name: "gitsync-" + ds.metadata.name,
      },
      spec: {
        selector: {
          matchLabels: {
            name: "gitsync-" + ds.metadata.name,
          }
        },
        template: {
          metadata: {
            labels: {
              name: "gitsync-" + ds.metadata.name,
            },
            annotations: {
              "checksum/config": '{{ tpl (.Files.Glob "scripts/gitsync/*").AsConfig . | sha256sum }}'
            },
          },
          spec: {
            nodeSelector: { gitsync: "all" },
            securityContext: { runAsUser: 0 },
            containers: [ {
              name: "git-sync",
              image: "{{ .Values.gitsync.daemonset.image.repository }}:{{ .Values.gitsync.daemonset.image.tag }}",
              imagePullPolicy: "{{ .Values.gitsync.daemonset.image.pullPolicy }}",
              command: ["/bin/sh"],
              args: ["-c", "/bin/sh /scripts/git-config.sh && /git-sync"],
              env: [
                { name: "GIT_SYNC_REPO", value: url },
                { name: "GIT_SYNC_ROOT", value: "/git/" + ds.metadata.name },
                { name: "GIT_SYNC_DEST", value: ds.metadata.name },
                { name: "GIT_SYNC_DEPTH", value: "1" },
                { name: "GIT_SYNC_WAIT", value: wait },
                { name: "GIT_SYNC_BRANCH", value: branch },
                { name: "GIT_SYNC_SSH", value: if use_secret then "1" else "0" },
                { name: "GIT_KNOWN_HOSTS", value: "0" },
              ],
              volumeMounts: [
                { mountPath: "/git", name: "git-volume" },
                { mountPath: "/scripts", name: "scripts" },
              ] + if use_secret then [
                { mountPath: "/etc/git-secret", name: "git-cred", readOnly: true }
              ] else [],
              resources: {
                limits: {
                  cpu: "1000m",
                  memory: "2000Mi",
                },
                requests: {
                  cpu: "3m",
                  memory: "4Mi",
                }
              }
            } ],
            initContainers: [ {
              name: "init",
              image: "{{ .Values.gitsync.daemonset.image.repository }}:{{ .Values.gitsync.daemonset.image.tag }}",
              imagePullPolicy: "{{ .Values.gitsync.daemonset.image.pullPolicy }}",
              env: [
                { name: "GIT_SYNC_REPO", value: url },
                { name: "GIT_SYNC_ROOT", value: "/git/" + ds.metadata.name },
                { name: "GIT_SYNC_DEST", value: ds.metadata.name },
                {{- if .Values.gitsync.daemonset.delayInit }}
                { name: "GIT_SYNC_DELAY_INIT", value: "TRUE" },
                {{- end }}
              ],
              command: ["sh", "/scripts/init.sh"],
              volumeMounts: [
                { mountPath: "/git", name: "git-volume" },
                { mountPath: "/scripts", name: "scripts" },
              ],
            } ],
            tolerations: [
              { effect: "NoSchedule", key: "hub.jupyter.org/dedicated", operator: "Equal", value: "user" },
              { effect: "NoSchedule", key: "nvidia.com/gpu", operator: "Exists" }
            ],
            volumes: [ {
              name: "git-volume",
              hostPath: {
                path: hostPath,
              }
            }, {
              name: "scripts",
              configMap: {
                name: "primehub-gitsync-scripts"
              }
            } ] + if use_secret then [ {
              name: "git-cred",
              secret: {
                defaultMode: 256,
                secretName: secret,
              }
            } ] else [],
          }
        }
      },
    },
  ]
}
