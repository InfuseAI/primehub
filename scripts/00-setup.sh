#!/bin/bash

SCRIPTS_ROOT=$(dirname "${BASH_SOURCE[0]}"); source $SCRIPTS_ROOT/common.sh

# install helm
kubectl --namespace kube-system create sa tiller
kubectl create clusterrolebinding tiller \
       --clusterrole cluster-admin \
       --serviceaccount=kube-system:tiller
helm init --service-account tiller --wait --upgrade

# install nginx-ingress
# We will use port 8080, hence *.10.88.88.88.xip.io:8080 to access all services.
# Enable this through port-forward for the nginx controller
# kubectl port-forward -n nginx-ingress svc/nginx-ingress-controller 8080:80 --address 10.88.88.88 &

helm install --namespace nginx-ingress -n nginx-ingress stable/nginx-ingress --set controller.hostNetwork=true

# setup storage dynamic-provisioner
# install local provisioner and make it as default provisioner 
# see also https://kubernetes.io/docs/tasks/administer-cluster/change-default-storage-class/
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.beta.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
