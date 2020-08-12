#!/bin/bash

if [ "$START_SSH" == "true" ]; then

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

    # Start publickey api server
    if command -v nohup &>/dev/null; then
        nohup python /usr/local/bin/start-notebook.d/publickey_api.py &
    fi
fi
