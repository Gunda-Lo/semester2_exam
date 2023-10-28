Automated LAMP Stack Deployment with Ansible
This guide outlines the process of automating the deployment of a LAMP (Linux, Apache, MySQL, PHP) stack on a "slave" node from a "master" node. It also includes instructions for copying files between nodes, configuring SSH, and using Ansible for provisioning.

Provisioning Virtual Machines
To begin, a Bash script is used to provision two virtual machines, designating one as the "master" and the other as the "slave." The script also configures the IP addresses and passwords for these VMs. The Vagrantfile used for this setup can be found here.

Accessing the Master Node
After provisioning the virtual machines, files are copied from the host machine to the master node using the scp command. An example command might look like:

scp /path/to/local/file/filename vagrant@master:/destination/path/on/vm

Next, you access the master node using the following command:

vagrant ssh master

Restart the system
sudo reboot

Wait a minute and relogin using the vagrant command above

Installing Ansible
Ansible is installed on the master node by updating the package list and then installing Ansible:

sudo apt update
sudo apt install ansible -y

SSH Key-Based Authentication
To ensure passwordless communication between the master and slave nodes, SSH key-based authentication is set up. The following steps are performed:

Generate an SSH key pair:

ssh-keygen -t rsa -b 4096

Copy the public key to the slave node:

ssh-copy-id -i ~/.ssh/id_rsa.pub vagrant@192.168.56.6

File Conversion
Since the scripts are copied from a Windows environment to a Unix environment, a file converter (dos2unix) is installed to make the scripts editable:

sudo apt install dos2unix -y

Then, convert the necessary files to Unix format:

dos2unix ~/LAMP.sh
dos2unix ~/lamp_setup.yaml

Ansible Inventory File
Create an Ansible inventory file (my_inventory.ini) to specify the target slave node:

echo "[slave]
192.168.56.6 ansible_ssh_user=vagrant ansible_ssh_private_key_file=~/.ssh/id_rsa" > my_inventory.ini

Executing the Ansible Playbook
Execute the Ansible playbook to automate the LAMP stack setup:

ansible-playbook -i my_inventory.ini lamp_setup.yaml

Verifying the Deployment
After running the playbook, the LAMP stack should be set up on the slave node. You can verify it by creating a PHP file in the default web server root directory. SSH into the slave node:

ssh vagrant@192.168.56.6

To test Laravel deployment on the slave node's IP address in a web browser connected on the host only network. (e.g., http://192.168.56.6)

That's it! The deployment of the LAMP stack and testing has been successfully automated using Ansible.

Links
[Vagrantfile](/vagrantfile.sh)
[Ansible Playbook](/lamp_setup.yaml)
[LAMP Stack Setup Script](/LAMP.sh)
[Laravel Test page](/laravel.png)
[Play screen](/playbook.png)