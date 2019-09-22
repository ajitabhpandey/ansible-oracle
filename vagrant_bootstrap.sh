#!/bin/sh

echo "Use 'vagrant status' command to find out the machine status"

TARGET_DEVICE="/dev/sdb"
MOUNT_POINT="/opt/oradata"
FILESYSTEM="ext4"

# Create a type 83 (linux) partition on a whole disk
echo "${TARGET_DEVICE}1: Id=83" | sudo sfdisk ${TARGET_DEVICE}

# Create ext4 filesystem
if [ ${FILESYSTEM} == 'ext4']
then
  sudo mkfs.ext4 ${TARGET_DEVICE}1
fi

# Create a desired mount point if it does not already exists
if [ -d "${MOUNT_POINT}" ]
then
  echo "${MOUNT_PONT} exists and is a directory"
elif [ -h "${MOUNT_POINT}" ]
then
  echo "${MOUNT_POINT} exists and is a symlink to $(readlink -f ${MOUNT_PONT})"
elif [ -f "${MOUNT_PONT}" ]
then
  echo "${MOUNT_POINT} exists and is a file"
else
  echo "Creating ${MOUNT_POINT}"
  sudo mkdir ${MOUNT_POINT}
fi

# Mount under the disk under the mount point
sudo mount ${TARGET_DEVICE}1 ${MOUNT_POINT}

# Find UUID of the TARGET_DEVICE
UUID=$(blkid ${TARGET_DEVICE}1 | awk '{print $2}')
echo -e '${UUID} ${MOUNT_POINT} \t ${FILESYSTEM} \t defaults \t 0 0'   >> /etc/fstab

# Copy the software packages to /tmp to facilitate ansible deployment
sudo cp /vagrant/provision/files/*.rpm /tmp
sudo cp /vagrant/provision/files/*.zip /tmp

# Disable SELinux
sudo setenforce permissive



