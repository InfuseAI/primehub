#!/bin/bash

echo "Basic Info"
whoami
echo $HOME
python --version
id jovyan
JUPYTER_USER_EXISTS="$?"
command -v sudo
SUDO_EXISTS="$?"

if [ $JUPYTER_USER_EXISTS != "0" ]; then
  # by default, we set the HOME at /home/jovyan
  # it might drive jupyter process crash, 
  # because of inconsistent python runtime requirement at /home/jovyan/.local 
  export HOME=/root
  echo "reset HOME to root"
fi

echo "Install jupyter_kernel_gateway "
pip install --user jupyter_kernel_gateway

echo "Start Kernel Gateway"
if [ -f "/usr/local/bin/start.sh" ]; then
  echo "found base-notebook scripts"
  chown -R 1000:100 /home/jovyan/.local
  . /usr/local/bin/start.sh $HOME/.local/bin/jupyter-kernelgateway --port 8889
else
  echo "we don't know who you are"
  $HOME/.local/bin/jupyter-kernelgateway --port 8889
fi


