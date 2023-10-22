Automated LAMP stack deplyment on a slave node from the master, with a cloned GitHub php repo, deployed using Ansible

First you write a bash script to provision two virtual machines, designatingone as 'master'and the other as 'slave'.
Link to vagrantfile: [Vagrantfile](/vagrantfile.sh)

Then you copy the files you would like to use from the host machine to the master node:
sudo scp /path/to/local/file/filename master:/destination/path/on/vm

Next you access the master node using thsi command:
vagrant ssh master

Then you install ansible on the master node:
sudo apt update
sudo apt install ansible -y

To ensure passwordless communication between the master and slave we nedd to configure ssh key-based authentication
ssh-keygen
ssh-copy-id vagrant@192.168.56.6

As we copied the scripts from a windows environment to a unix environment, we need to install a file converter, to make the scripts editable.
sudo apt install dos2unix -y

Convert the necessary files to unix format
dos2unix ~/LAMP.sh

dos2unix ~/lamp_setup.yaml

Create your ansible inventory file:
echo "[slave]
192.168.56.6 ansible_ssh_user=vagrant ansible_ssh_private_key_file=~/.ssh/id_rsa" > my_inventory.ini

Execute the playbook:
ansible-playbook -i my_inventory.ini lamp_setup.yaml
![slave-monitor](/slave-monitor.png)
![terminal-monitor](/terminal-monitor.png)

Link to playbook: [ansible](/lamp_setup.yaml)
Link to LAMP script: [LAMP](/LAMP.sh)

SSH into the slave, create a php file in the defeault web server root directory.
ssh vagrant@192.168.56.6

echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/phpinfo.php

Verify the apche2 and php installation
Type the ip address of the slave node in the web browser of the remote server 192.168.56.6, to test php, add the name of the php file earlier created: 192.168.56.6./phpinfo.php
![apache-test](/apache2-test.png)
![php-test](/php-test.png)
