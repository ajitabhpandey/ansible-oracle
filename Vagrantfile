# -*- mode: ruby -*-
# vi: set ft=ruby :

# Variables
var_vm_name     = 'centos7_ora18x_vagrant'
var_mem         = 4096
var_cpus        = 2
var_disk1       = './centos7_18x_oradata.vdi'
var_disk_size   = 5

Vagrant.configure("2") do |config|
    # Vagrant Box (check https://app.vagrantup.com/boxes/search for more boxes)
    config.vm.box       = 'centos/7'

    # Set the hostname
    #config.vm.hostname  = centos7_ora18x_vagrant

    # This is the name Vagrant outputs on the console
    # use vagrant ssh <this_name> to connect to the machine.
    # If you do not specify this, then it will be set to 'default'
    config.vm.define :centos7_ora18x_vagrant do |t|
    end

    # Port Forwarding from host to guest for Oracle
  
    config.vm.network "forwarded_port", guest: 8080, host: 8080
    config.vm.network "forwarded_port", guest: 8443, host: 8443
    config.vm.network "forwarded_port", guest: 1521, host: 1521
    config.vm.network "forwarded_port", guest: 5500, host: 5500

    # Provider specific VM configuration. We are using VirtualBox provider.
    config.vm.provider "virtualbox" do |vb|
        vb.name     = var_vm_name
        vb.cpus     = var_cpus
        vb.memory   = var_mem

        unless File.exist?(var_disk1)
            vb.customize ['createhd', '--filename', var_disk1, '--size', var_disk_size * 1024]
        end
        # Check the controller name if you get the error 
        # 'VBoxManage: error: Could not find a controller named ...'
        # VBoxManage showvminfo centos7_18x_vagrant|grep 'Storage Controller Name'
        vb.customize ['storageattach', :id, '--storagectl', 'IDE', '--port', 1, '--device', 0, '--type', 'hdd', '--nonrotational', 'on', '--medium', var_disk1]
    end # end provider virtualbox  

    # Use ansible provisioner
    config.vm.provision "shell", inline: <<-SHELL
        echo "Use 'vagrant status' command to find out the machine status"
    SHELL
end