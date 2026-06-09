# 🖥️ Vagrant + Ansible Lab

> Automated 3-VM lab: one Ansible control node managing two Ubuntu nodes via key-based SSH — provisioned end-to-end with a single `vagrant up`, zero manual setup.

---

## 📌 Overview

This project provisions a local DevOps lab using **Vagrant** and **VirtualBox**, then uses **Ansible** to automatically configure the managed nodes. It demonstrates core DevOps skills: infrastructure as code, configuration management, SSH key distribution, and idempotent provisioning.

```
┌─────────────────────────────────────────────────────────┐
│  Host Machine  (Windows / macOS / Linux)                │
│                                                         │
│  ┌─────────────────────┐    private network             │
│  │  ansible            │ ──── SSH ────▶  pc1            │
│  │  192.168.56.10      │ ──── SSH ────▶  pc2            │
│  │  control node       │                                │
│  └─────────────────────┘                                │
└─────────────────────────────────────────────────────────┘
```

---

## 🛠️ Tech Stack

| Tool | Purpose |
|---|---|
| Vagrant 2.4 | VM lifecycle management |
| VirtualBox 7.0 | Hypervisor |
| Ansible 2.17 | Configuration management |
| Ubuntu 22.04 LTS | OS for all VMs |
| Bash | Provisioning scripts |

---

## 🖥️ VM Specifications

| Name | Role | IP Address | RAM |
|---|---|---|---|
| `ansible` | Control Node | 192.168.56.10 | 1024 MB |
| `pc1` | Managed Node | 192.168.56.11 | 512 MB |
| `pc2` | Managed Node | 192.168.56.12 | 512 MB |

---

## ⚡ Quick Start

**Requirements:** Vagrant ≥ 2.3 and VirtualBox ≥ 7.0

```bash
# 1. Install the required Vagrant plugin (once)
vagrant plugin install vagrant-hostmanager

# 2. Boot all three VMs — provisioning runs automatically
vagrant up

# 3. SSH into the control node
vagrant ssh ansible

# 4. Ping all machines
ansible all -m ping
```

---

## 📸 Screenshots

### Connectivity Check — `ansible all -m ping`
![ping](screenshots/1_ping.png)

### Playbook Run — `ansible-playbook ~/ansible/site.yml`
![playbook](screenshots/2_playbook.png)

### Ad-hoc — `ansible managed_nodes -m shell -a "uptime"`
![uptime](screenshots/3_uptime.png)

### Ad-hoc — `ansible managed_nodes -m shell -a "df -h"`
![df-h](screenshots/4_df-h.png)

### Ad-hoc — `ansible pc1 -m shell -a "hostname -I"`
![hostname](screenshots/5_hostname.png)

---

## 📁 Project Structure

```
vagrant-ansible/
├── Vagrantfile                         ← VM definitions, loop-driven config block
├── provision-node.sh                   ← bootstraps pc1 and pc2
├── provision-ansible.sh                ← installs Ansible, distributes keys, runs playbook
└── ansible/
    ├── ansible.cfg                     ← absolute paths, interpreter pinned
    ├── inventory.ini                   ← managed_nodes group (pc1 + pc2)
    ├── site.yml                        ← master playbook
    └── roles/common/
        ├── tasks/main.yml              ← packages, hosts, users, SSH hardening
        └── handlers/main.yml           ← restart SSH on config change
```

---

## 🔧 What the Playbook Configures

Each managed node (pc1 & pc2) gets:

- ✅ Apt cache updated and common packages installed (`vim`, `curl`, `git`, `htop`, `python3`, etc.)
- ✅ Timezone set to UTC
- ✅ Hostname configured correctly
- ✅ `/etc/hosts` populated with all lab node IPs
- ✅ Shared `labadmin` user created with sudo access
- ✅ Ansible control node key authorized for `labadmin`
- ✅ SSH hardened — root login and password auth disabled

---

## 💻 Useful Commands

```bash
# Run the full playbook
ansible-playbook ~/ansible/site.yml

# Dry run — no changes applied
ansible-playbook ~/ansible/site.yml --check

# Ad-hoc commands
ansible managed_nodes -m shell -a "uptime"
ansible managed_nodes -m shell -a "df -h"
ansible pc1 -m shell -a "hostname -I"

# Vagrant controls
vagrant halt            # graceful shutdown
vagrant destroy -f      # delete all VMs
vagrant up --provision  # re-run provisioners
```

---

## 🐛 Challenges & Solutions

| # | Problem | Solution |
|---|---|---|
| 01 | `ssh-keygen` failed on Windows at Vagrantfile parse time | Moved all key generation inside the Linux VM provisioner |
| 02 | Vagrant synced folder is `777` — Ansible ignores `ansible.cfg` | Write `ansible.cfg` to home directory during provisioning; export `ANSIBLE_CONFIG` via `.bashrc` |
| 03 | `handlers:` block inside `tasks/main.yml` caused YAML parse error | Moved handler to correct location: `roles/common/handlers/main.yml` |
| 04 | Relative inventory path broke outside the `ansible/` directory | Changed to absolute path `/home/vagrant/ansible/inventory.ini` in `ansible.cfg` |

---

## 📂 Related Projects

- [jpetstore-vagrant](https://github.com/jemarzan/jpetstore-vagrant) — Automated 3-tier web app: Nginx → Tomcat → MariaDB

---

*Built by [jemarzan](https://github.com/jemarzan) · DevOps Practitioner · Learning by building 🚀*
