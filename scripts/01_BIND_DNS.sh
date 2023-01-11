#! /bin/bash -e

# Install and configure BIND DNS

# Install
dnf install bind bind-utils -y

# Apply configuration
\cp ${BASE_DIR_PATH}/dns/named.conf /etc/named.conf
cp -R ${BASE_DIR_PATH}/dns/zones /etc/named/

# Configure the firewall for DNS
firewall-cmd --add-port=53/udp --zone=internal --permanent

# for OCP 4.9 and later 53/tcp is required
firewall-cmd --add-port=53/tcp --zone=internal --permanent
firewall-cmd --reload

# Enable and start the service
systemctl enable named
systemctl start named
systemctl status named

# At the moment DNS will still be pointing to the LAN DNS server. You can see this by testing with dig ocp.lan.
# Change the LAN nic (ens192) to use 127.0.0.1 for DNS AND ensure Ignore automatically Obtained DNS parameters is ticked
nmcli con mod ens160 ipv4.dns "127.0.0.1"

# Restart Network Manager
systemctl restart NetworkManager

# Confirm dig now sees the correct DNS results by using the DNS Server running locally
dig ocp.lan

# The following should return the answer ocp-bootstrap.lab.ocp.lan from the local server
dig -x 192.168.22.200