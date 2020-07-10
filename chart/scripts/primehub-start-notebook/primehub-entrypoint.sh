#!/bin/bash
# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

echo "original args: $@"

## Launch the standard process
if command -v tini &>/dev/null && command -v start-notebook.sh; then
    echo "start the standard notebook command"
    export PRIMEHUB_LAUNCH_MODE=standard
    start-notebook.sh $@ --NotebookApp.default_url=/lab
    exit 0
fi

if [[ $JUPYTER_IMAGE == *"primehub.airgap"* ]]; then
  echo "Any images are not supported in AIRGAP env"
  exit 1
fi


## Run start-notebook.d
for s in $(find /usr/local/bin/start-notebook.d -type l -name "*.sh"); do
  grep sudo $s &>/dev/null || {
    echo "execute scritps $s"
    . $s
  }
done

## Change Working Directory
cd /home/jovyan

## Launch the non-standard process
if command -v jupyter-labhub &>/dev/null; then
    export PRIMEHUB_LAUNCH_MODE=labhub
    pip install jupyterhub
    jupyterhub-singleuser --allow-root --NotebookApp.default_url=/lab --NotebookApp.notebook_dir=/home/jovyan $@
    exit 0
fi

echo "jupyter notebook --allow-root --NotebookApp.base_url=$JUPYTERHUB_SERVICE_PREFIX --NotebookApp.token=$JUPYTERHUB_API_TOKEN $@"
export PRIMEHUB_LAUNCH_MODE=notebook

# TODO token not working well with jupyterhub
#jupyter notebook --allow-root --NotebookApp.base_url=$JUPYTERHUB_SERVICE_PREFIX --NotebookApp.default_url=/lab --NotebookApp.token=$JUPYTERHUB_API_TOKEN $@

# kubeflow set no authz, because it depends on istio
# https://www.kubeflow.org/docs/notebooks/custom-notebook/
jupyter notebook --allow-root --NotebookApp.notebook_dir=/home/jovyan  --NotebookApp.base_url=$JUPYTERHUB_SERVICE_PREFIX --NotebookApp.default_url=/lab --NotebookApp.token='' --NotebookApp.password='' $@
