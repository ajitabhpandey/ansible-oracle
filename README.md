# ansible-oracle

Deploying oracle using ansible

## Requirement

The Oracle Express Edition (XE) RPM should be downloaded and placed in **provision/files** directory before proceeding with the setup. So a tree structure after cloning the repository may look like below - 
```
➜ ansible-oracle (master) ✗ tree
.
├── LICENSE
├── README.md
├── Vagrantfile
├── centos7_18x_oradata.vdi
├── provision
│   ├── files
│   │   ├── oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm
│   │   └── oracle-database-xe-18c-1.0-1.x86_64.rpm
│   └── ora18cxe.yml
└── vagrant_bootstrap.sh
```

The VDI file visible in the above setup is the additional data disk I created to hold the Oracle database and backups etc.

## Vagrant Build

A simple Vagrant build on CentOS 7.x works. By default the shell provisioner - 'bootstrap' runs for the first time. In order to call the ansible provisioner along with shell provisioner, use the below command - 
`$ vagrant up --provision-with bootstrap,ansible_local`
or, after the node is already up if a need to reprovision comes due to changes in ansible files, following command can be run with rebuilding the box.
`$ vagrant provision --provision-with ansible_local`

NOTE - The first time ansible provisioner has bailed out in the middle during the oracle DB configuration. I had to run the ansible provisioner again and it has worked. This needs to be more researched.

## Docker Image Build Using Packer

To build an image with oracle XE and APEX, use the following command - 
`packer build ora18cxeapx19_packer.json`