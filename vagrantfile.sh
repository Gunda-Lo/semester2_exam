#!/bin/bash

# Variables
ubuntu_box="ubuntu/focal64"
master_ip="192.168.56.5"
slave_ip="192.168.56.6"

# Passwords for master and slave VMs
master_password="segunda"
slave_password="segunda"

# Function to configure a VM
configure_vm() {
    local vm_name="$1"
    local vm_ip="$2"
    local vm_password="$3"

    cat <<EOF >> Vagrantfile
  config.vm.define "$vm_name" do |$vm_name|
    $vm_name.vm.hostname = "$vm_name"
    $vm_name.vm.box = "$ubuntu_box"
    $vm_name.vm.network "private_network", type: "static", ip: "$vm_ip"
    
    # Set the password for SSH
    $vm_name.vm.provision "shell", inline: "echo -e '$vm_password\n$vm_password' | sudo passwd vagrant"
    
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
  def configure_vm(config, name, ip, password)
    config.vm.define name do |vm|
      vm.vm.hostname = name
      vm.vm.box = "$ubuntu_box"
      vm.vm.network "private_network", type: "static", ip: ip
      
      # Set the password for SSH
      vm.vm.provision "shell", inline: "echo -e '$password\n$password' | sudo passwd vagrant"
      
      vm.vm.provision "shell" do |s|
        s.inline = "sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt install sshpass -y && sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config && sudo systemctl restart ssh && sudo apt-get install -y avahi-daemon libnss-mdns"
      end
    end
  end

EOF

# Configure the "master" VM
configure_vm "master" "$master_ip" "$master_password"

# Configure the "slave" VM
configure_vm "slave" "$slave_ip" "$slave_password"

# Close the Vagrantfile
cat <<'EOF' >> Vagrantfile
  # Set VM provider settings
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
    vb.cpus = 2
  end
end
EOF

# Start the Vagrant VMs
vagrant up