#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
PRIMEHUB_VERSION=${PRIMEHUB_VERSION:-LOCAL}
GCP_SA_JSON_FILE=${GCP_SA_JSON_FILE:-gcp-sa.json}

check_env() {
  command -v lsb_release > /dev/null || (echo "Is it Ubuntu or Debian?"; exit 1;)
  command -v apt-get > /dev/null || (echo "Require 'apt-get' command"; exit 1;)
  command -v apt-key > /dev/null || (echo "Require 'apt-key' command"; exit 1;)
}  

install_required_bins() {
  if [[ ! -f /etc/apt/sources.list.d/docker.list ]]; then
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  fi
  apt-get -yy -qq --no-install-recommends update
  apt-get -yy -qq --no-install-recommends install docker-ce docker-ce-cli wget jq
  wget -q https://github.com/mikefarah/yq/releases/download/v4.2.0/yq_linux_amd64.tar.gz -O - |\
    tar xz && mv yq_linux_amd64 /usr/bin/yq
  echo "Docker, jq, and yq installed"
  echo
}

install_google_cloud_sdk() {
  # Install GCP SDK (https://cloud.google.com/sdk/docs/downloads-apt-get)
  export CLOUD_SDK_REPO="cloud-sdk-buster"
  if [[ ! -f /etc/apt/sources.list.d/google-cloud-sdk.list ]]; then
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
  fi
  echo "Add GPG key..."
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  echo "Apt Install..."
  apt-get -yy -qq --no-install-recommends update
  apt-get -yy -qq --no-install-recommends install google-cloud-sdk
  echo "Cloud SDK installed"
}

check_env

if [[ $PRIMEHUB_VERSION == "LOCAL" ]]; then
  PRIMEHUB_VERSION=$(cat $DIR/../../chart/Chart.yaml | grep appVersion | cut -d' ' -f2)
  if [[ $PRIMEHUB_VERSION == "" || $PRIMEHUB_VERSION == "LOCAL" ]]; then
    echo "Require vaild PRIMEHUB_VERSION env. Got '$PRIMEHUB_VERSION'.";
    exit 1;
  fi
fi

if [[ ! -f $GCP_SA_JSON_FILE ]]; then
  echo "Require valid json key file for Google Cloud SDK service account"
  echo "Rename the key file to 'gcp-sa.json' or specify GCP_SA_JSON_FILE=<keyfile>"
  exit 1;
fi

# install tools
echo "[Install] Required Binaries"
install_required_bins
echo "[Install] Google Cloud SDK"
install_google_cloud_sdk

gcloud auth activate-service-account gitlab-ci@infuseai-dev.iam.gserviceaccount.com --key-file=<(cat $GCP_SA_JSON_FILE)

mkdir -p $DIR/build

echo
echo "[Build] primehub images"
echo
$DIR/image-save.sh -f $DIR/../../chart/images.yaml -o $DIR/build/primehub-images-ee-$PRIMEHUB_VERSION primehub-ee
$DIR/image-save.sh -f $DIR/../../chart/images.yaml -o $DIR/build/primehub-images-deploy-$PRIMEHUB_VERSION primehub-deploy
echo
echo "[Build] cert-manager images"
echo
$DIR/image-save.sh -f $DIR/images.yaml -o $DIR/build/cert-manager-images cert-manager
echo
echo "[Build] nginx-ingress images"
echo
$DIR/image-save.sh -f $DIR/images.yaml -o $DIR/build/nginx-images-images nginx-ingress

echo
echo "[Upload] images"
for file in $(ls -1 $DIR/build/*); do
  echo "upload $file"
  gsutil cp $file gs://primehub-release/$PRIMEHUB_VERSION/
done

echo
echo "[Done]"
