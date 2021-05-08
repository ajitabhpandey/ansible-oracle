# ansible-oracle

Deploying oracle using ansible.

NOTE - This setup at this moment installs the entire stack, Oracle, Apex, ORDS-on-tomcat in one machine.

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
│   │   ├── oracle-database-xe-18c-1.0-1.x86_64.rpm
|   |   ├── apex_19.2_en.zip
│   │   └── ords-19.2.0.199.1647.zip
│   └── ora18cxe.yml
└── vagrant_bootstrap.sh
```

The VDI file visible in the above setup is the additional data disk I created to hold the Oracle database and backups etc. while building on my local laptop.

## Vagrant Build

A simple Vagrant build on CentOS 7.x works. By default the shell provisioner - 'bootstrap' runs for the first time. In order to call the ansible provisioner along with shell provisioner, use the below command - 
`$ vagrant up --provision-with bootstrap,ansible_local`
or, after the node is already up if a need to reprovision comes due to changes in ansible files, following command can be run with rebuilding the box.
`$ vagrant provision --provision-with ansible_local`

## Ansible Build

If you have an existing machine, ansible playbooks can be called directly to build it. However, since at present there is no mechanism in the playbook to place the software files on the target server, please note that the expectation is that the source files of Oracle APEX, ORDS, XE and the XE-Preinstall files should be in the /tmp directory on the server. Perhaps in time I will expand this to include a playbook to copy the source files for installation on the target server. 

`$ ansible-playbook -i 192.168.5.168, --private-key ~/.ssh/id_rsa -e 'ansible_ssh_user=root' provision/main.yml`

The main.yml playbook includes four different playbooks for installing oracle, apexi, tomcat  and ords respectively in that order. Depending on the requirement, any of these playbooks can be directly called upon - 

`$ ansible-playbook -i 192.168.5.168, --private-key ~/.ssh/id_rsa -e 'ansible_ssh_user=root' provision/ora18cxe.yml`

`$ ansible-playbook -i 192.168.5.168, --private-key ~/.ssh/id_rsa -e 'ansible_ssh_user=root' provision/apex_install.yml`

`$ ansible-playbook -i 192.168.5.168, --private-key ~/.ssh/id_rsa -e 'ansible_ssh_user=root' provision/tomcat.yml`

`$ ansible-playbook -i 192.168.5.168, --private-key ~/.ssh/id_rsa -e 'ansible_ssh_user=root' provision/ords_install.yml`

## Docker Image Build Using Packer

To build an image with oracle XE and APEX, use the following command - 
`packer build ora18cxeapx19_packer.json`


# Ansible Playbooks

Few ansible playbooks have been stitched together to deploy the stack. Each of these playbooks can be used independent of each other. ORDS and Tomcat are linked together as ords is the application need to run in a Java application server, but minor changes can remove that dependency.

## main.yml

This playbook includes other playbooks which are to be run on the target.

### Variables

None so far.

## ora18cxe.yml

This playbook installs Oracle 18c XE.

### Variables

| Variable    | Purpose                                                                                               | Default Value                    |
|-------------|-------------------------------------------------------------------------------------------------------|----------------------------------|
| ORADATA     | This directory stores database files such as control files, (tablespace-) data files, redo log files. | /opt/oradata                     |
| ORACLE_BASE | Base location for Oracle software.                                                                    | /opt/oracle                      |
| ORACLE_HOME | It is below ORACLE_BASE and contains the files for each database.                                     | /opt/oracle/product/18c/dbhomeXE |

## apex_install.yml

This playbook installs the Oracle APEX application.

### Variables

| Variable                       | Purpose                                                                                    | Default Value             |
|--------------------------------|--------------------------------------------------------------------------------------------|---------------------------|
| CONTAINER_NAME                 | This is the PDB which will be created                                                      | XEPDB1                    |
| APEX_ARCHIVE                   | APEX installation zip file name. This file should exists in /tmp directory on target host. | apex_19.2_en.zip          |
| APEX_DEST_LOCATION             | Location where apex zip will be unpacked                                                   | /opt                      |
| APEX_TABLESPACE                | Tablespace where APEX software will be installed                                           | APEX_TABSPACE             |
| APEX_TABLESPACE_DATA_FILE      | Datafile on which the above tablespace will be created                                     | xe_apex_tabspace_01.dat   |
| APEX_PUBLIC_USER_PASSWORD      | Password for APEX_PUBLIC_USER                                                              | Passw0rd123               |
| APEX_LISTENER_PASSWORD         | Password for APEX_LISTENER                                                                 | Passw0rd123               |
| APEX_REST_PUBLIC_USER_PASSWORD | Password for APEX_REST_PUBLIC_USER                                                         | Passw0rd123               |
| APEX_ADMIN_USER                | User name for APEX ADMIN user                                                              | ADMIN                     |
| APEX_ADMIN_USER_EMAIL_ADDRESS  | Email address for APEX ADMIN user                                                          | support@domain.com        |
| APEX_ADMIN_USER_PASSWORD       | Password for APEX ADMIN user                                                               | Passw0rd123               |
| APEX_ADMIN_USER_PRIVILEGES     | Privileges for APEX ADMIN user (leave it untouched unless you know what you are doing)     | ADMIN                     |
| ORACLE_USER                    | User which will own the apex application                                                   | oracle                    |
| ORACLE_GROUP                   | Group which will own the apex application                                                  | dba                       |

## ords_install.yml

### Variables

| Variable                       | Purpose                                                                                    | Default Value             |
|--------------------------------|--------------------------------------------------------------------------------------------|---------------------------|
| CONTAINER_NAME                 | This is the PDB which will be created                                                      | XEPDB1                    |
| APEX_ARCHIVE                   | APEX installation zip file name. This file should exists in /tmp directory on target host. | apex_19.2_en.zip          |
| APEX_DEST_LOCATION             | Location where apex zip will be unpacked                                                   | /opt                      |
| ORDS_ARCHIVE                | ORDS installation zip file name. This file should exists in /tmp directory on target host.                                           | ords-19.2.0.199.1647.zip             |
| ORDS_DEST_LOCATION      | Location where ORDS zip file will be unpacked                                     | /opt/ords   |
| ORDS_CONFIG_DIRETORY      | Configuration directory for ORDS                                                              | /opt/ords/conf               |
| ORDS_TABLESPACE         | Tablespace where ORDS will be installed                                                                 | ORDS_TABSPACE               |
| ORDS_TABLESPACE_DATA_FILE | Datafile on which ORDS tablespace will be created                                                         | xe_ords_tabspace_01.dat               |
| APEX_PUBLIC_USER_PASSWORD                | Password for APEX_PUBLIC_USER                                                              | Passw0rd123                     |
| APEX_LISTENER_PASSWORD  | Password for APEX_LISTENER                                                          | Passw0rd123        |
| APEX_REST_PUBLIC_USER_PASSWORD       | Password for APEX_REST_PUBLIC user                                                               | Passw0rd123               |
| ORDS_PUBLIC_USER_PASSWORD     | Password for ORDS_PUBLIC user     | Passw0rd123                     |
| SYS_PASSWORD     | Password for SYS user     | Passw0rd123                     |
| ORACLE_USER                    | User which will own the apex application                                                   | oracle                    |
| ORACLE_GROUP                   | Group which will own the apex application                                                  | dba                       |
| TOMCAT_USER                    | User which will own the tomcat application                                                   | tomcat                    |
| TOMCAT_GROUP                   | Group which will own the tomcat application                                                  | tomcat                       |
| TOMCAT_WEBAPPS                   | Directory where tomcat webapplication are present                                                  | /opt/tomcat/latest/webapps                       |


## tomcat.yml

Installs the tomcat downloaded from apache website

### Variables

| Variable                | Purpose                                                                                                                                                            | Default Value                                                                          |
|-------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------|
| TOMCAT_MAJOR_VERSION    | Tomcat major version which is going to be installed                                                                                                                | 9                                                                                      |
| TOMCAT_MINOR_VERSION    | Tomcat minor version which is going to be installed                                                                                                                | 0.45                                                                                   |
| TOMCAT_VERSION          | Full Tomcat version to be installed                                                                                                                                | 9.0.45                                                                                 |
| TOMCAT_DOWNLOAD_LINK    | Location from where the tomcat archive is to be downloaded                                                                                                         | http://archive.apache.org/dist/tomcat/tomcat-9/v9.0.45/bin/apache-tomcat-9.0.45.tar.gz |
| TOMCAT_INSTALL_LOCATION | Target directory  where tomcat will be unarchived (installed)                                                                                                      | /opt/tomcat                                                                            |
| TOMCAT_USER             | Operating system user running tomcat application                                                                                                                   | tomcat                                                                                 |
| TOMCAT_GROUP            | Operating system group running tomcat application                                                                                                                  | tomcat                                                                                 |
| TOMCAT_PORT             | Port on which tomcat service will listen                                                                                                                           | 8080                                                                                   |
| CATALINA_HOME           | Location where tomcat is installed (its a symlink to the latest version of tomcat)                                                                                 | /opt/tomcat/latest                                                                     |
| CATALINA_OPTS           | Java runtime options used when the "start" or "run" command is executed. The values here can only be used by Tomcat application.                                   | -Xms512M -Xmx1024M -server -XX:+UseParallelGC                                          |
| JAVA_HOME               | Points to JDK location. Required to run with DEBUG argument. We are just pointing it to JRE location.                                                              | /usr/lib/jvm/jre                                                                       |
| JRE_HOME                | Points to JRE installtion.                                                                                                                                         | /usr/lib/jvm/jre                                                                       |
| JAVA_OPTS               | Java runtime options used when the "start", "stop" or "run" command is executed. The value of this variable can also be used by other JAVA applications installed. | -Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom                       |

# Licence

BSD

