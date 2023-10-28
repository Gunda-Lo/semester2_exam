#!/bin/bash

# Variables
ubuntu_box="ubuntu/focal64"
master_ip="192.168.56.5"
slave_ip="192.168.56.6"

# Function to configure a VM
configure_vm() {
    local vm_name="$1"
    local vm_ip="$2"

    cat <<EOF >> Vagrantfile
  config.vm.define "$vm_name" do |$vm_name|
    $vm_name.vm.hostname = "$vm_name"
    $vm_name.vm.box = "$ubuntu_box"
    $vm_name.vm.network "private_network", type: "static", ip: "$vm_ip"
    
    # Configure SSH key for passwordless authentication
    $vm_name.ssh.insert_key = false # Disable Vagrant's default key insertion

    $vm_name.vm.provision "shell" do |s|
      s.inline = "sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt install sshpass -y && sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config && sudo systemctl restart ssh && sudo apt-get install -y avahi-daemon libnss-mdns"
    end
  end
EOF
}

# Initialize Vagrant with Ubuntu Focal64 box
vagrant init "$ubuntu_box"

# Create the Vagrantfile with VM configuration
cat <<'EOF' > Vagrantfile
Vagrant.configure("2") do |config|

  # Define a function to configure VMs
  def configure_vm(config, name, ip)
    config.vm.define name do |vm|
      vm.vm.hostname = name
      vm.vm.box = "$ubuntu_box"
      vm.vm.network "private_network", type: "static", ip: ip
      
      # Configure SSH key for passwordless authentication
      vm.ssh.insert_key = false # Disable Vagrant's default key insertion
      
      vm.vm.provision "shell" do |s|
        s.inline = "sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt install sshpass -y && sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config && sudo systemctl restart ssh && sudo apt-get install -y avahi-daemon libnss-mdns"
      end
    end
  end

EOF

# Configure the "master" VM
configure_vm "master" "$master_ip"

# Configure the "slave" VM
configure_vm "slave" "$slave_ip"

# Close the Vagrantfile
cat <<'EOF' >> Vagrantfile
  # Set VM provider settings
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
  end
end
EOF

# Generate an SSH key pair on the host
ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa

# Copy the host's public key to the VMs for passwordless authentication
vagrant up
ssh-copy-id -i ~/.ssh/id_rsa vagrant@$master_ip
ssh-copy-id -i ~/.ssh/id_rsa vagrant@$slave_ip