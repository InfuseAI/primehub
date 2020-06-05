#!/bin/bash
chk_url() {
  status=$(curl -sL -o /dev/null --connect-timeout 10 -w "%{http_code}" $1)
  echo "[$status] $1"
  if [[ ! $status =~ [23].. ]]; then return 1; fi
}

endpoints=(
  http://${PRIMEHUB_DOMAIN}:${PRIMEHUB_PORT}/console/landing
  http://${PRIMEHUB_DOMAIN}:${PRIMEHUB_PORT}/console/cms
  http://${PRIMEHUB_DOMAIN}:${PRIMEHUB_PORT}/hub/home
  # add /hub/home is because
  # 'nginx.ingress.kubernetes.io/app-root' cannot redirect with port even
  # 'use-port-in-redirects' is set
  # https://github.com/kubernetes/ingress-nginx/issues/2810#issuecomment-407575135
  http://${PRIMEHUB_DOMAIN}:${PRIMEHUB_PORT}
)

now=$SECONDS
timeout=900

for endpoint in "${endpoints[@]}"; do
  echo "try $endpoint"
  until chk_url $endpoint; do
    if (( $SECONDS - now > $timeout )); then
      echo "timeout ${timeout}s"
      exit 1;
    fi
    sleep 5;
  done;
done;

echo "tests finished"
