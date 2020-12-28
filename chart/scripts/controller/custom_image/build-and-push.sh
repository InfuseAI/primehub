#!/bin/bash

readonly INIT_FAILED=1
readonly BUILD_FAILED=2
readonly PUSH_FAILED=3

readonly PUSH_SECRET_AUTHFILE=/push-secret/.dockerconfigjson
readonly PULL_SECRET_AUTHFILE=/pull-secret/.dockerconfigjson

readonly SKIP_TLS_VERIFY={SKIP_TLS_VERIFY:-false}

function init() {
  echo "[Step: init]"
  echo "Generating Dockerfile"
  echo "$DOCKERFILE" > /Dockerfile
  [[ $? -ne 0 ]] && { exit $INIT_FAILED; }
  echo
}

function build() {
  local -a AUTHFILE_FLAGS
  echo "[Step: build]"
  echo "Fetching base image: $BASE_IMAGE"
  if [ -f $PULL_SECRET_AUTHFILE ]; then
    AUTHFILE_FLAGS+=(--authfile "$PULL_SECRET_AUTHFILE")
  fi
  buildah --storage-driver overlay "${AUTHFILE_FLAGS[@]}" pull $BASE_IMAGE
  echo
  echo "Obtaining USER from $BASE_IMAGE"
  user=$(buildah --storage-driver overlay inspect --format '{{.OCIv1.Config.User}}' $BASE_IMAGE)
  if [[ -n $user ]]; then
    echo "Appending 'USER $user' to Dockerfile"
    echo "USER $user" >> /Dockerfile
  else
    echo "Failed to obtain. Skipped"
  fi
  echo
  echo "Building image: $TARGET_IMAGE"
  buildah --storage-driver overlay bud -f /Dockerfile -t $TARGET_IMAGE .
  [[ $? -ne 0 ]] && { exit $BUILD_FAILED; }
  echo
}

function push() {
  echo "[Step: push]"
  if [ "$SKIP_TLS_VERIFY" == "true" ]; then
    buildah --storage-driver overlay --authfile $PUSH_SECRET_AUTHFILE push --tls-verify=false --format docker $TARGET_IMAGE
  else
    buildah --storage-driver overlay --authfile $PUSH_SECRET_AUTHFILE push --format docker $TARGET_IMAGE
  fi
  [[ $? -ne 0 ]] && { exit $PUSH_FAILED; }
  echo
}

function completed() {
  echo "[Completed]"
  buildah --storage-driver overlay images
  echo
}

init
build
push
completed
