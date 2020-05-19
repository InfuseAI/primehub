#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
mkdir -p /etc/jupyter
cat "${DIR}/extra_notebook_config.py" >> /etc/jupyter/jupyter_notebook_config.py

