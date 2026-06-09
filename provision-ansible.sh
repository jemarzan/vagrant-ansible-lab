#!/usr/bin/env bash
# ==============================================================================
# provision-ansible.sh — Applied to the Ansible control node
# ==============================================================================
set -euo pipefail

echo ">>> [ansible] Starting control node provisioning..."

export DEBIAN_FRONTEND=noninteractive

# --- Install Ansible ---
apt-get update -qq
apt-get install -y -qq software-properties-common
add-apt-repository -y ppa:ansible/ansible
apt-get update -qq
apt-get install -y -qq ansible sshpass

# --- Generate SSH key pair for the vagrant user ---
sudo -u vagrant bash -c '
  mkdir -p ~/.ssh && chmod 700 ~/.ssh
  if [ ! -f ~/.ssh/ansible_id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -N "" \
      -f ~/.ssh/ansible_id_rsa \
      -C "ansible@lab"
  fi

  # Disable strict host checking for the private network
  cat > ~/.ssh/config << SSHCONF
Host 192.168.56.*
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    IdentityFile ~/.ssh/ansible_id_rsa
SSHCONF
  chmod 600 ~/.ssh/config
'

# --- Copy public key to pc1 and pc2 using vagrant default insecure key ---
PUB_KEY=$(cat /home/vagrant/.ssh/ansible_id_rsa.pub)

for HOST in pc1 pc2; do
  echo ">>> Pushing SSH key to ${HOST}..."
  VAGRANT_KEY="/vagrant/.vagrant/machines/${HOST}/virtualbox/private_key"
  ssh -o StrictHostKeyChecking=no \
      -o UserKnownHostsFile=/dev/null \
      -i "${VAGRANT_KEY}" \
      vagrant@${HOST} \
      "mkdir -p ~/.ssh && chmod 700 ~/.ssh &&
       echo '${PUB_KEY}' >> ~/.ssh/authorized_keys &&
       chmod 600 ~/.ssh/authorized_keys"
  echo ">>> Key installed on ${HOST} ✓"
done

# --- Populate /etc/hosts ---
cat >> /etc/hosts << HOSTS
192.168.56.10  ansible
192.168.56.11  pc1
192.168.56.12  pc2
HOSTS

# --- Fix ansible.cfg ---
# 1. Vagrant synced folders are always 777 and cannot be chmod'd permanently,
#    so Ansible will always ignore ansible.cfg inside ~/ansible/.
#    Solution: write a clean ansible.cfg directly into the home directory
#    with absolute paths — this file is never world-writable.
# 2. Set interpreter_python to silence the Python discovery warnings.
cat > /home/vagrant/ansible.cfg << ACFG
[defaults]
inventory           = /home/vagrant/ansible/inventory.ini
remote_user         = vagrant
private_key_file    = /home/vagrant/.ssh/ansible_id_rsa
host_key_checking   = False
retry_files_enabled = False
stdout_callback     = yaml
interpreter_python  = /usr/bin/python3

[privilege_escalation]
become        = True
become_method = sudo
become_user   = root
ACFG
chown vagrant:vagrant /home/vagrant/ansible.cfg

# Persist ANSIBLE_CONFIG in .bashrc so it survives re-logins
grep -qxF 'export ANSIBLE_CONFIG=~/ansible.cfg' /home/vagrant/.bashrc \
  || echo 'export ANSIBLE_CONFIG=~/ansible.cfg' >> /home/vagrant/.bashrc

# Export it now for the remainder of this provisioning session
export ANSIBLE_CONFIG=/home/vagrant/ansible.cfg

# --- Test connectivity then run the playbook ---
echo ">>> Testing Ansible connectivity..."
sudo -u vagrant bash -c '
  export ANSIBLE_CONFIG=~/ansible.cfg
  ansible all -m ping
  echo ">>> Running site.yml..."
  ansible-playbook ~/ansible/site.yml
'

echo ""
echo "============================================"
echo "  Lab is ready!"
echo "  ansible  → 192.168.56.10"
echo "  pc1      → 192.168.56.11"
echo "  pc2      → 192.168.56.12"
echo ""
echo "  vagrant ssh ansible"
echo "  ansible all -m ping"
echo "============================================"