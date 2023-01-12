# Install and configure Apache Web Server

set -x

# Install Apache
dnf install httpd -y

# Change default listen port to 8080 in httpd.conf
sed -i 's/Listen 80/Listen 0.0.0.0:8080/' /etc/httpd/conf/httpd.conf

# Configure the firewall for Web Server traffic
firewall-cmd --add-port=8080/tcp --zone=internal --permanent
firewall-cmd --reload

# Enable and start the service
systemctl enable httpd
systemctl start httpd
systemctl is-active --quiet httpd && echo httpd service is running

# Making a GET request to localhost on port 8080 should now return the default Apache webpage
curl localhost:8080