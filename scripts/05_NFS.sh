#! /bin/bash -e

# Install and configure NFS for the OpenShift Registry. It is a requirement to provide storage for the Registry, emptyDir can be specified if necessary.

# Install NFS Server
dnf install nfs-utils -y

# Create the Share
# Check available disk space and its location df -h
mkdir -p /shares/registry
chown -R nobody:nobody /shares/registry
chmod -R 777 /shares/registry

# Export the Share
echo "/shares/registry  192.168.22.0/24(rw,sync,root_squash,no_subtree_check,no_wdelay)" > /etc/exports
exportfs -rv

# Set Firewall rules:
firewall-cmd --zone=internal --add-service mountd --permanent
firewall-cmd --zone=internal --add-service rpc-bind --permanent
firewall-cmd --zone=internal --add-service nfs --permanent
firewall-cmd --reload

# Enable and start the NFS related services
systemctl enable nfs-server rpcbind
systemctl start nfs-server rpcbind nfs-mountd
