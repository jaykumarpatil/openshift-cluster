#! /bin/bash -e

# Install HAProxy
dnf install haproxy -y

# Copy HAProxy config
\cp ${BASE_DIR_PATH}/haproxy.cfg /etc/haproxy/haproxy.cfg

# Configure the Firewall
# Note: Opening port 9000 in the external zone allows access to HAProxy stats that are useful for monitoring and troubleshooting. The UI can be accessed at: http://{ocp-svc_IP_address}:9000/stats
firewall-cmd --add-port=6443/tcp --zone=internal --permanent # kube-api-server on control plane nodes
firewall-cmd --add-port=6443/tcp --zone=external --permanent # kube-api-server on control plane nodes
firewall-cmd --add-port=22623/tcp --zone=internal --permanent # machine-config server
firewall-cmd --add-service=http --zone=internal --permanent # web services hosted on worker nodes
firewall-cmd --add-service=http --zone=external --permanent # web services hosted on worker nodes
firewall-cmd --add-service=https --zone=internal --permanent # web services hosted on worker nodes
firewall-cmd --add-service=https --zone=external --permanent # web services hosted on worker nodes
firewall-cmd --add-port=9000/tcp --zone=external --permanent # HAProxy Stats
firewall-cmd --reload

# Enable and start the service
setsebool -P haproxy_connect_any 1 # SELinux name_bind access
systemctl enable haproxy
systemctl start haproxy
systemctl status haproxy