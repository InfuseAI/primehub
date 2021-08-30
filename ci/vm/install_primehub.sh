#!/bin/bash

# Wait for cloud-init to finish
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done

# Install PrimeHub
PRIMEHUB_VERSION=$1

# We want microk8s group take effect immediately
export PRIMEHUB_DOMAIN=hub.primehub.local
export PH_PASSWORD=passw0rd
export KC_PASSWORD=passw0rd

./primehub-install create singlenode --k8s-version 1.21 && ./primehub-install create primehub --primehub-version ${PRIMEHUB_VERSION}
