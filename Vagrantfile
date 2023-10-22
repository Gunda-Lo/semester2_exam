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

  config.vm.define "master" do |master|
    master.vm.hostname = "master"
    master.vm.box = "ubuntu/focal64"
    master.vm.network "private_network", type: "static", ip: "192.168.56.5"
    
    # Set the password for SSH
    master.vm.provision "shell", inline: "echo -e 'segunda\nsegunda' | sudo passwd vagrant"
    
    master.vm.provision "shell" do |s|
      s.inline = "sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt install sshpass -y && sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config && sudo systemctl restart ssh && sudo apt-get install -y avahi-daemon libnss-mdns"
    end
  end
  config.vm.define "slave" do |slave|
    slave.vm.hostname = "slave"
    slave.vm.box = "ubuntu/focal64"
    slave.vm.network "private_network", type: "static", ip: "192.168.56.6"
    
    # Set the password for SSH
    slave.vm.provision "shell", inline: "echo -e 'segunda\nsegunda' | sudo passwd vagrant"
    
    slave.vm.provision "shell" do |s|
      s.inline = "sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt install sshpass -y && sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config && sudo systemctl restart ssh && sudo apt-get install -y avahi-daemon libnss-mdns"
    end
  end
  # Set VM provider settings
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
    vb.cpus = 2
  end
end
