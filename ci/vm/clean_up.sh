#!/bin/bash

# Remove microk8s.containerd to avoid failed to reserve sandbox name issue
microk8s.stop
sudo rm -rf /var/snap/microk8s/common/var/lib/containerd

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
      dhcp4:yes
EOF