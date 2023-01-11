#! /bin/bash -e

# Install & configure DHCP

# Install the DHCP Server
dnf install dhcp-server -y

# Edit dhcpd.conf from the cloned git repo to have the correct mac address for each host and copy the conf file to the correct location for the DHCP service to use
\cp ${BASE_DIR_PATH}/dhcpd.conf /etc/dhcp/dhcpd.conf

# Configure the Firewall
firewall-cmd --add-service=dhcp --zone=internal --permanent
firewall-cmd --reload

# Enable and start the service
systemctl enable dhcpd
systemctl start dhcpd
systemctl status dhcpd