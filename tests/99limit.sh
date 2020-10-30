#!/bin/bash

kubectl get pod  --all-namespaces  -o=custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,MEMLIMITS:.spec.containers[*].resources.limits.memory,MEMREQUESTS:.spec.containers[*].resources.requests.memory,CPULIMITS:.spec.containers[*].resources.limits.cpu,CPUQUESTS:.spec.containers[*].resources.requests.cpu,STATUS:.status.phase' \
  | grep -v '^kube-system' \
  | grep -v '^nginx-ingress' \
  | grep -v '^local-path-storage'

memory_cpu_limits=$(kubectl get pod --all-namespaces -o=custom-columns='NAMESPACE:.metadata.namespace,MEMLIMITS:.spec.containers[*].resources.limits.memory,CPULIMITS:.spec.containers[*].resources.limits.cpu,STATUS:.status.phase' \
  | grep -v 'Terminating' \
  | grep -v '^kube-system' \
  | grep -v '^nginx-ingress' \
  | grep -v '^local-path-storage' \
  | grep -v '^default' \
  | grep -v '^metacontroller')
none_pattern="<none>"
if [[ $memory_cpu_limits =~ $none_pattern ]]; then
    echo "[ERROR] All Primehub's pods should have cpu/memory limits"
    #exit 1
fi

echo "tests finished"
