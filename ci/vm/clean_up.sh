#!/bin/bash

# Remove microk8s.containerd to avoid failed to reserve sandbox name issue
microk8s.stop
sudo rm -rf /var/snap/microk8s/common/var/lib/containerd

# microk8s.stop disabled services, we need to enable it back
sudo systemctl list-unit-files | grep microk8s | awk '{print $1}' | xargs sudo systemctl enable

# Remove cloud-init to speed up the boot in virtualbox
sudo touch /etc/cloud/cloud-init.disabled
sudo apt remove cloud-init --yes
sudo rm -rf /etc/cloud/; sudo rm -rf /var/lib/cloud/

# Setup network in virtualbox
sudo rm /etc/netplan/50-cloud-init.yaml
sudo bash -c "cat > /etc/netplan/config.yaml" <<'EOF'
network:
  version: 2
  renderer: networkd
  ethernets:
    id0:
      match:
        name: en*
      dhcp4: yes
EOF
sudo bash -c "echo '@reboot /usr/sbin/netplan apply' | crontab -"