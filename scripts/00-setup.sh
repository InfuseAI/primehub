#!/bin/bash

SCRIPTS_ROOT=$(dirname "${BASH_SOURCE[0]}"); source $SCRIPTS_ROOT/common.sh

# install helm
kubectl --namespace kube-system create sa tiller
kubectl create clusterrolebinding tiller \
       --clusterrole cluster-admin \
       --serviceaccount=kube-system:tiller
helm init --service-account tiller --wait --upgrade

# install nginx-ingress
helm install --namespace nginx-ingress -n nginx-ingress stable/nginx-ingress --set controller.hostNetwork=true

# setup storage dynamic-provisioner
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.beta.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
