#!/bin/bash

ensure_sshd() {
    # Check installed sshd
    if command -v sshd &>/dev/null; then
        echo "Starting sshd"
        mkdir /run/sshd
        $(command -v sshd) &
    else
        if [ $(id -u) == 0 ] ; then
            # Install openssh server via APT
            if command -v apt-get &>/dev/null; then
                echo "Installing openssh-server via APT"
                apt-get update -q && apt-get install openssh-server --no-install-recommends -yq
            fi

            # Start sshd
            if command -v sshd &>/dev/null; then
                echo "Starting sshd"
                mkdir /run/sshd
                $(command -v sshd) &
            else
                echo "Unable to install sshd"
            fi
        else
            echo "No permission to install sshd"
        fi
    fi
}

prepare_user_volume() {
  # Fix the home directory too open issue
  if [ -e $HOME ]; then
    chmod 755 $HOME
  fi

  # Only create .ssh when found NB_ variables
  if [ -z ${NB_UID=+x} || -z ${NB_GID=+x} ]; then
    return
  fi

  # Prepare default .ssh directory and setup permission
  if [ ! -d $HOME/.ssh ]; then
    mkdir -p $HOME/.ssh
    chmod 700 $HOME/.ssh
    touch $HOME/.ssh/authorized_keys
    chmod 644 $HOME/.ssh/authorized_keys
    chown -R $NB_UID:$NB_GID $HOME/.ssh
  fi
}

if [ "$PRIMEHUB_START_SSH" == "true" ]; then
    ensure_sshd &
    prepare_user_volume

    # Start publickey api server
    if command -v nohup &>/dev/null; then
        nohup python /usr/local/bin/start-notebook.d/publickey_api.py &
    fi
fi
