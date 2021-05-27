#!/usr/bin/env bash
set -euo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
REGISTRY=primehub.airgap:5000
REGISTRY_TYPE='docker-registry'
USER=''
PASSWORD=''

function print_usage() {
  echo "Push to airgap registry"
  echo ""
  echo "Usage: "
  echo "  `basename $0` <images.txt> [<images.tgz>]"
  echo ""
  echo "Options: "
  echo "  -u  set the username of the registry server"
  echo "  -p  set the password of the registry server"
  echo "  -h  print this help"
  echo "  -r  set the registry server to push (default \"${REGISTRY}\")"
  echo ""
  echo "Examples: "
  echo "  # load and push image "
  echo "  `basename $0` path/to/images.txt"
  echo ""
  echo "  # load and push image (the same behavior as above)"
  echo "  `basename $0` path/to/images.txt path/to/images.tgz"
  echo ""
  echo "  # load and push image with specific registry name"
  echo "  `basename $0` -r registry.primehub.local:5000 path/to/images.txt"
  echo ""
}

function is_harbor_registry() {
  local registry=$1
  if curl -s --fail -k https://${registry}/api/v2.0/health > /dev/null; then
    return 0
  fi
  return 1
}

function create_project() {
  local project=${1}
  curl -k -s -u "${USER}:${PASSWORD}" -X POST -H "Content-Type: application/json" "https://${REGISTRY}/api/v2.0/projects" -d \
"{
  \"project_name\": \"${project}\",
  \"public\": true
}" > /dev/null
}

while getopts "u:p:r:h" OPT; do
  case $OPT in
    u)
      USER=$OPTARG
      ;;
    p)
      PASSWORD=$OPTARG
      ;;
    r)
      REGISTRY=$OPTARG
      ;;
    h)
      print_usage
      exit
      ;;
  esac
done
shift $(expr $OPTIND - 1 )

# Remaining argument
if [[ $# -eq 1 ]]; then
  IMAGES_LIST=$1
  IMAGES_FILE="$(dirname $IMAGES_LIST)/$(basename -s .txt $IMAGES_LIST).tgz"
elif [[ $# -eq 2 ]]; then
  IMAGES_LIST=$1
  IMAGES_FILE=$2
else
  print_usage
  exit
fi

if is_harbor_registry ${REGISTRY}; then
  REGISTRY_TYPE='harbor'
fi

echo "images.txt: $IMAGES_LIST"
echo "images.tgz: $IMAGES_FILE"
echo "registry:   $REGISTRY"
echo "type:       $REGISTRY_TYPE"
echo "username:   $USER"
echo

if [[ ! -f $IMAGES_LIST ]]; then
  echo "$IMAGES_LIST not found"
  exit
fi

if [[ ! -f $IMAGES_FILE ]]; then
  echo "$IMAGES_FILE not found"
  exit
fi

if [[ ${REGISTRY_TYPE} == 'harbor' ]]; then
  if [[ ${USER} == '' || ${PASSWORD} == '' ]]; then
    echo "Should provide username and password when registry type is 'Harbor'"
    echo
    print_usage
    exit
  fi
fi

if [[ ${USER} != '' && ${PASSWORD} != '' ]]; then
  echo "login ${REGISTRY} ..."
  echo ${PASSWORD} | docker login ${REGISTRY} -u ${USER} --password-stdin
fi

# load to docker file
echo "load images..."
docker load -i $IMAGES_FILE

echo "push images..."
# push to registry
for image in `cat $IMAGES_LIST`; do
  tag=$(echo $image | cut -d':' -f2)
  project=$(echo $image | cut -d':' -f1 | cut -d'/' -f1)
  push_image=$image

  if [[ "$(echo $image | cut -d':' -f1)" != *"/"* ]]; then
    project='library'
    push_image="library/${image}"
  fi

  if [[ ${REGISTRY_TYPE} == 'harbor' ]]; then
    echo "create project ${project}"
    create_project ${project}
  fi

  echo "push ${image}"
  docker tag ${image} ${REGISTRY}/${push_image}
  docker push ${REGISTRY}/${push_image}
done
