#!/bin/bash

sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get -yy -q --no-install-recommends install \
  iptables \
  ebtables \
  ethtool \
  ca-certificates \
  conntrack \
  socat \
  git \
  nfs-common \
  glusterfs-client \
  cifs-utils \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg2 \
  software-properties-common \
  bridge-utils \
  ipcalc \
  aufs-tools \
  sudo \
  openssh-client \
  build-essential \
  net-tools \
  libgtk-3-0 libx11-xcb1 libnss3 libasound2 libxss1 libx11-xcb1 libnss3 libasound2 libxss1 libxtst6 fonts-wqy-zenhei libxcb-dri3-dev libdrm2 libgbm1 # e2e related
sudo DEBIAN_FRONTEND=noninteractive apt-get clean
sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install kubectl
curl -sLO https://storage.googleapis.com/kubernetes-release/release/v1.17.5/bin/linux/amd64/kubectl && \
  chmod a+x kubectl && \
  sudo mv kubectl /usr/local/bin

K3D_VERSION=4.4.7
HELM_VERSION=3.6.2
HELMFILE_VERSION=v0.144.0
NVM_VERSION=0.39.0
NODEJS_VERSION=14.18.0

# Install k3d
curl -sLo k3d https://github.com/rancher/k3d/releases/download/v${K3D_VERSION}/k3d-linux-amd64 && \
  chmod +x k3d && \
  sudo mv k3d /usr/local/bin/

# Install helm
curl -ssL https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar -xz --strip-components 1 linux-amd64/helm && \
  chmod +x helm && \
  sudo mv helm /usr/local/bin

# Install helmfile
curl -sLo helmfile https://github.com/roboll/helmfile/releases/download/${HELMFILE_VERSION}/helmfile_linux_amd64 && \
  chmod +x helmfile && \
  sudo mv helmfile /usr/local/bin

# Install jq
curl -sLo jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 && \
  chmod +x jq && \
  sudo mv jq /usr/local/bin

# Install yq
curl -sLo yq https://github.com/mikefarah/yq/releases/download/v4.9.8/yq_linux_amd64 && \
  chmod +x yq && \
  sudo mv yq /usr/local/bin

# Install node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash && bash -c 'source ~/.bashrc && nvm install v'${NODEJS_VERSION}' && npm install @cucumber/cucumber@8.4.0 puppeteer@15.5.0 chai@4.3.6 cucumber-html-reporter@5.5.0'
