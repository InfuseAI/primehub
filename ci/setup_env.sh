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

KIND_VERSION=0.7.0
HELM_VERSION=2.16.1

# Install kind
curl -sLo kind https://github.com/kubernetes-sigs/kind/releases/download/v${KIND_VERSION}/kind-linux-amd64 && \
  chmod +x kind && \
  sudo mv kind /usr/local/bin/

# Install helm
curl -ssL https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar -xz --strip-components 1 linux-amd64/helm && \
  chmod +x helm && \
  sudo mv helm /usr/local/bin

# Install helmfile
curl -sLo helmfile https://github.com/roboll/helmfile/releases/download/v0.40.3/helmfile_linux_amd64 && \
  chmod +x helmfile && \
  sudo mv helmfile /usr/local/bin

# Install jq
curl -sLo jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 && \
  chmod +x jq && \
  sudo mv jq /usr/local/bin

# Install yq
curl -sLo yq https://github.com/mikefarah/yq/releases/download/2.1.2/yq_linux_amd64 && \
  chmod +x yq && \
  sudo mv yq /usr/local/bin

# Install node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash && bash -c 'source ~/.bashrc && nvm install 11.1 && npm install cucumber puppeteer chai'
