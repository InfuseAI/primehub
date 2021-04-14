#!/bin/bash

# Wait for cloud-init to finish
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done

# Enable password and set default password
sudo sed -i "s/.*PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config
echo -e "passw0rd\npassw0rd" | sudo passwd ubuntu
sudo systemctl restart sshd

# Modify hostname
sudo hostname primehub-ee-trial
sudo bash -c 'echo primehub-ee-trial > /etc/hostname'

# Add hub.primehub.local to etc hosts
sudo bash -c 'echo "127.0.0.1 hub.primehub.local" >> /etc/hosts'

# Update system
sudo apt update

# Get primehub-installer
curl -O https://storage.googleapis.com/primehub-release/bin/primehub-install
chmod +x primehub-install

# Install microk8s
./primehub-install create singlenode --k8s-version 1.17 || true

# Reboot to relogin with microk8s group
sudo reboot now