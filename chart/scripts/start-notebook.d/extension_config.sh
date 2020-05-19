#! /bin/bash

appendix_dir="$(dirname "$0")"

# Enable extension jupyter-tensorboard when tensorboard and jupyter-tensorboard installed
if (sudo -u ${NB_USER} /opt/conda/bin/pip list --disable-pip-version-check 2>&1 | grep -q '^tensorboard') && (sudo -u ${NB_USER} /opt/conda/bin/pip list --disable-pip-version-check 2>&1 | grep -q '^jupyter-tensorboard'); then
  echo "Import tensorboard extension..."
  sudo -u ${NB_USER} mkdir -p /opt/conda/etc/jupyter/jupyter_notebook_config.d/
  sudo -u ${NB_USER} cat "${appendix_dir}/start-notebook.d/tensorboard-serverextension.json" > /opt/conda/etc/jupyter/jupyter_notebook_config.d/tensorboard-serverextension.json
  sudo -u ${NB_USER} mkdir -p /opt/conda/etc/jupyter/nbconfig/tree.d/
  sudo -u ${NB_USER} cat "${appendix_dir}/start-notebook.d/tensorboard-nbextension-tree.json" > /opt/conda/etc/jupyter/nbconfig/tree.d/tensorboard-nbextension-tree.json
fi

