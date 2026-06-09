#!/usr/bin/env bash
# ==============================================================================
# provision-node.sh — Applied to pc1 and pc2 (managed nodes)
# ==============================================================================
set -euo pipefail

echo ">>> [$(hostname)] Starting node provisioning..."

# Allow vagrant user to sudo without a password
echo "vagrant ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vagrant
chmod 440 /etc/sudoers.d/vagrant

# Update packages and install common tools
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq \
  vim curl wget git \
  htop net-tools tree \
  python3 python3-pip

# Populate /etc/hosts with all lab nodes
cat >> /etc/hosts << HOSTS
192.168.56.10  ansible
192.168.56.11  pc1
192.168.56.12  pc2
HOSTS

echo ">>> [$(hostname)] Node provisioning complete ✓"
