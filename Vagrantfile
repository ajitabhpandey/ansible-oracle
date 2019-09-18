# -*- mode: ruby -*-
# vi: set ft=ruby :

# Variables
vm_name     = 'centos7_ora18x_vagrant'
total_mem   = 4096
num_cpus    = 2
disk1       = './centos7_18x_oradata.vdi'
disk_size   = 5

# Save the hostname into '.vagrant_hostname' file.
VAGRANT_HOSTNAME = '.vagrant_hostname'

# If this file exists then VM is already setup and hostname has been set
if File.exist? VAGRANT_HOSTNAME
  hostname = IO.read( VAGRANT_HOSTNAME ).strip
else
  hostname = "Ora18cXE-#{SecureRandom.hex(2)}-centos7.dev.local"
  IO.write( VAGRANT_HOSTNAME, hostname )
end

Vagrant.configure("2") do |config|
    # Vagrant Box (check https://app.vagrantup.com/boxes/search for more boxes)
    config.vm.box       = 'centos/7'

    # Set the hostname
    config.vm.hostname  = hostname

    # This is the name Vagrant outputs on the console
    # use vagrant ssh <this_name> to connect to the machine.
    # If you do not specify this, then it will be set to 'default'
    config.vm.define vm_name do |t|
    end

    # Port Forwarding from host to guest for Oracle
  
    config.vm.network "forwarded_port", guest: 8080, host: 8080
    config.vm.network "forwarded_port", guest: 8443, host: 8443
    config.vm.network "forwarded_port", guest: 1521, host: 1521
    config.vm.network "forwarded_port", guest: 5500, host: 5500

    # Provider specific VM configuration. We are using VirtualBox provider.
    config.vm.provider "virtualbox" do |vb|
        vb.name     = vm_name
        vb.cpus     = num_cpus
        vb.memory   = total_mem

        unless File.exist?(disk1)
            vb.customize ['createhd', '--filename', disk1, '--size', disk_size * 1024]
        end
        # Check the controller name if you get the error 
        # 'VBoxManage: error: Could not find a controller named ...'
        # VBoxManage showvminfo centos7_18x_vagrant|grep 'Storage Controller Name'
        vb.customize ['storageattach', :id, '--storagectl', 'IDE', '--port', 1, '--device', 0, '--type', 'hdd', '--nonrotational', 'on', '--medium', disk1]
    end # end provider virtualbox 

    # Use Shell provisioner to bootstrap the system. Unless explicitly called, the will be
    # run once
    config.vm.provision "bootstrap", type: "shell", path: "vagrant_bootstrap.sh"

    # Use ansible provisioner to deploy required applications on the system. This will 
    # never run, unless explicitly called
    config.vm.provision "ansible_local", type: "ansible", run: "never" do |ansible|
      ansible.playbook = "provision/ora18cxe.yml"
      ansible.verbose = true
    end

end

# Remove the file containing the hostname if the command is vagrant destroy
if ARGV[0] == "destroy"
    File.delete VAGRANT_HOSTNAME
end

