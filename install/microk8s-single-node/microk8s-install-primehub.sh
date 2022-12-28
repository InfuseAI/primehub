#!/bin/bash
# set -x  #debug script
GREEN='\033[0;32m'
SKYBLUE='\033[0;36m'
NC='\033[0m'

# install utils
function utils-install {
    # mkdir bin folder and update linux package
    echo -e "${GREEN} [Setting] Generate bin folder and Update Linux package. (1/8) ${NC}"
    mkdir -p ~/bin
	sudo apt update

	# Install yq
    echo -e "${GREEN} [Install] snap package: yq (2/8) ${NC}"
    sudo snap install yq

    # Install Others
    echo -e "${GREEN} [Install] apt package (3/8) ${NC}"
    for linux_package in make jq git curl netcat; do
        echo -e "${GREEN} * Install ${linux_package} ${NC}"
        sudo apt install -y ${linux_package}
    done

	# Install Helm
    echo -e "${GREEN} [Install] helm (4/8) ${NC}"
    curl -LO https://get.helm.sh/helm-v3.5.4-linux-amd64.tar.gz
    tar -zxvf helm-v3.5.4-linux-amd64.tar.gz
    install linux-amd64/helm ~/bin

    # Install helm-diff
    echo -e "${GREEN} [Install] helm-diff (5/8) ${NC}"
    helm plugin install https://github.com/databus23/helm-diff

    # Install helmfile
    echo -e "${GREEN} [Install] helmfile (6/8) ${NC}"
    curl -Lo helmfile https://github.com/roboll/helmfile/releases/download/v0.144.0/helmfile_linux_amd64
    install helmfile ~/bin

    echo -e "${GREEN} [Install] kubectl (7/8) ${KUBECTL_VERSION} ${NC}"
    curl --output ~/bin/kubectl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
        && chmod 755 ~/bin/kubectl \
        && ln -nfs ~/bin/kubectl ~/bin/k
    
    echo -e "${GREEN} [Setting] Export bin folder (8/8) ${KUBECTL_VERSION} ${NC}"
    echo "export PATH=$HOME/bin:$PATH" >> ~/.bashrc
    source ~/.bashrc
}

function microk8s-install {
    K8S_VERSION=1.21

    echo -e "${GREEN} [Install] microk8s ${K8S_VERSION} ${NC}"
    sudo snap install microk8s --classic --channel=${K8S_VERSION}/stable
    sudo usermod -a -G microk8s ubuntu
    sudo chown -f -R ubuntu ~/.kube

    echo -e "${GREEN} [Check] microk8s status ${NC}"
    local status=$(sudo microk8s.status --format short --wait-ready)

    if echo ${status} | grep "storage: disabled" > /dev/null; then
        echo -e "${GREEN} [Enable] microk8s addon: storage ${NC}"
        sudo microk8s.enable storage
    fi

    if echo ${status} | grep "dns: disabled" > /dev/null; then
        echo -e "${GREEN} [Enable] microk8s addon: dns ${NC}"
        sudo microk8s.enable dns
    fi

    if echo ${status} | grep "rbac: disabled" > /dev/null; then
        echo -e "${GREEN} [Enable] microk8s addon: rbac ${NC}"
        sudo microk8s.enable rbac
    fi

    echo -e "${GREEN} [Check] microk8s status ${NC}"
    sudo microk8s.status --wait-ready

    echo -e "${GREEN} [check] enable 'privileged' in kube-apiserver ${NC}"
    privileged=$(cat /var/snap/microk8s/current/args/kube-apiserver | grep '\-\-allow-privileged' || true)
    if [[ "${privileged}" == "" ]]; then
        warn "[Pre-check Failed] Not enable 'privileged' in kube-apiserver"
        echo -e "${GREEN} [Enable] 'privileged' in kube-apiserver ${NC}"
        echo "--allow-privileged" >> /var/snap/microk8s/current/args/kube-apiserver
        shouldRestart=true
    fi

    echo -e "${GREEN} [check] enable 'authentication-token-webhook' in kubelet ${NC}"
    auth_token_webhook=$(cat /var/snap/microk8s/current/args/kubelet | grep '\-\-authentication-token-webhook' || true)
    if [[ "${auth_token_webhook}" == "" ]]; then
        warn "[Pre-check Failed] Not enable 'authentication-token-webhook' in kubelet"
        echo -e "${GREEN} [Enable] 'authentication-token-webhook' in kubelet ${NC}"
        echo "--authentication-token-webhook=true" >> /var/snap/microk8s/current/args/kubelet
        shouldRestart=true
    fi

    docker_registry=$(cat /var/snap/microk8s/current/args/containerd-template.toml | grep '${INSECURE_REGISTRY}' || true)
  if [[ "${INSECURE_REGISTRY}" != "" && docker_registry != "" ]]; then
    echo -e "${GREEN} [Enable] Insecrue registry ${INSECURE_REGISTRY} ${NC}"
    local mirror=$(cat << EOF
        \[plugins.cri.registry.mirrors."${INSECURE_REGISTRY}"\]\n          endpoint = \[\"http:\/\/${INSECURE_REGISTRY}\"\]
EOF
)
    sed -i "s/\[plugins.cri.registry.mirrors\]/\[plugins.cri.registry.mirrors\]\n${mirror}/" /var/snap/microk8s/current/args/containerd-template.toml
  fi
}
function kubernetes-setting {
    echo -e "${GREEN} [Check] kube config ${NC}"
    mkdir -p ~/.kube
    sudo microk8s.kubectl config view --raw > ~/.kube/config
    chmod 600 ~/.kube/config
    kubectl get node

    echo -e "${GREEN} [check] k8s cluster ${NC}"
    kubectl cluster-info
    echo -e "${GREEN} [check] k8s node ${NC}"
    kubectl get node

    echo -e "${GREEN} [Info] Helm version ${NC}"
    helm version

    echo -e "${GREEN} [Check] Storage Class ${NC}"
    kubectl get storageclass

    echo -e "${GREEN} [Check] Nginx Ingress ${NC}"
    echo -e "${GREEN} [Install] Nginx Ingress ${NC}"
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm install nginx-ingress ingress-nginx/ingress-nginx --create-namespace --namespace ingress-nginx \
        --set controller.hostNetwork=true --set rbac.create=true --set defaultBackend.enabled=true --set tcp."2222"=hub/ssh-bastion-server:2222 \
        --set controller.admissionWebhooks.enabled=false \
        --set controller.resources.limits.cpu=250m \
        --set controller.resources.limits.memory=200Mi \
        --set controller.resources.requests.cpu=100m \
        --set controller.resources.requests.memory=100Mi \
        --set defaultBackend.resources.limits.cpu=250m \
        --set defaultBackend.resources.limits.memory=100Mi \
        --set defaultBackend.resources.requests.cpu=100m \
        --set defaultBackend.resources.requests.memory=64Mi
    kubectl -n ingress-nginx rollout status deploy/nginx-ingress-ingress-nginx-controller
    kubectl get svc -n ingress-nginx
}


function primeHub-install {
    echo -e "${GREEN} Clone the PrimeHub project from PrimeHub Github repo. ${NC}"
    git clone https://github.com/InfuseAI/primehub.git
    echo -e "${GREEN} Install and configure PrimeHub ${NC}"
    mv primehub-install ./primehub/install/primehub-install
    chmod 777 ./primehub/install/primehub-install
    ./primehub/install/primehub-install create primehub --primehub-version v3.11.0
}

export PATH=${PATH}:~/bin
export PRIMEHUB_DOMAIN=$1
export KC_PASSWORD=$2
export PH_PASSWORD=$3
echo -e "${SKYBLUE} ============== Variable ============== ${NC}"
echo -e "${SKYBLUE} PrimeHub Domain name: ${PRIMEHUB_DOMAIN} ${NC}"
echo -e "${SKYBLUE} Keycloak Password: ${KC_PASSWORD} ${NC}"
echo -e "${SKYBLUE} PrimeHub Password: ${PH_PASSWORD} ${NC}"
echo -e "${SKYBLUE} ====================================== ${NC}"

echo -e "${SKYBLUE} ====== Start installing PrimeHub ===== ${NC}"
echo -e "${GREEN} [1/4] Install Linux package ${NC}"
utils-install
echo -e "${GREEN} [2/4] Install Microk8s Kubernetes system. ${NC}"
microk8s-install
echo -e "${GREEN} [3/4] Configure Kubernetes system. ${NC}"
kubernetes-setting
echo -e "${GREEN} [4/4] Install PrimeHub platform. ${NC}"
primeHub-install
echo -e "${SKYBLUE} ===== Finish installing PrimeHub ===== ${NC}"