# ==============================================================================
# Vagrantfile — Ansible Lab
# Stack: Ansible Control Node (ansible) → Managed Nodes (pc1, pc2)
# Compatible with: VirtualBox
# Plugin required: vagrant plugin install vagrant-hostmanager
# ==============================================================================

# ==============================================================================
# CONFIG — Edit these for each project
# ==============================================================================

# --- Network ---
BASE_IP = "192.168.56"   # First 3 octets of your private network

# --- Box ---
UBUNTU_BOX = "ubuntu/jammy64"

# --- VMs ---
# name:      Vagrant identifier     → vagrant up <name>
# hostname:  Hostname inside the VM
# ip:        Last octet of private IP (combined with BASE_IP)
# box:       OS box to use
# memory:    RAM in MB
# provision: Shell script to run on first boot
# gui:       Show VirtualBox GUI window (true/false)

VMS = [
  { name: "pc1",     hostname: "pc1",     ip: "11", box: UBUNTU_BOX, memory: "512",  provision: "provision-node.sh",    gui: false },
  { name: "pc2",     hostname: "pc2",     ip: "12", box: UBUNTU_BOX, memory: "512",  provision: "provision-node.sh",    gui: false },
  { name: "ansible", hostname: "ansible", ip: "10", box: UBUNTU_BOX, memory: "1024", provision: "provision-ansible.sh", gui: false },
]

# ==============================================================================
# VAGRANTFILE — No need to edit below this line
# ==============================================================================

Vagrant.configure("2") do |config|

  # --- Host Manager Plugin ---
  # Automatically updates /etc/hosts on host machine and all guest VMs
  # so you can use hostnames (e.g. pc1, pc2, ansible) instead of IPs
  config.hostmanager.enabled     = true
  config.hostmanager.manage_host = true

  # --- Loop through each VM definition ---
  VMS.each do |vm|
    config.vm.define vm[:name] do |node|

      node.vm.box      = vm[:box]
      node.vm.hostname = vm[:hostname]

      # Private network IP — BASE_IP + last octet
      # e.g. 192.168.56.10 for ansible
      node.vm.network "private_network", ip: "#{BASE_IP}.#{vm[:ip]}"

      # Uncomment to add a public (bridged) network interface
      # node.vm.network "public_network"

      # VirtualBox settings
      node.vm.provider "virtualbox" do |vb|
        vb.memory = vm[:memory]
        vb.gui    = vm[:gui]
        vb.name   = vm[:name]   # readable name in VirtualBox UI
      end

      # Sync ansible/ folder into the control node only
      if vm[:name] == "ansible"
        node.vm.synced_folder "./ansible", "/home/vagrant/ansible",
          owner: "vagrant", group: "vagrant"
      end

      # Run provisioning script on first boot
      node.vm.provision "shell", path: vm[:provision]

    end
  end

end
