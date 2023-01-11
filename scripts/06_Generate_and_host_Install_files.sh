#! /bin/bash -e

set -x

BASE_DIR_PATH="${HOME}/openshift-cluster"
# Generate and host install files

RHCOS_DOWNLOAD_URL="https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/4.5/latest/rhcos-metal.x86_64.raw.gz"
RHCOS_RAW_FILE_NAME="rhcos.raw.gz"
wget -c "${RHCOS_DOWNLOAD_URL}" -o "$(${BASE_DIR_PATH}/${RHCOS_RAW_FILE_NAME})" -q --show-progress

# Generate an SSH key pair keeping all default options
ssh-keygen -q -t ed25519 -N '' <<< $'\ny' >/dev/null 2>&1

# Create an install directory
mkdir ${BASE_DIR_PATH}/ocp-install

# Copy the install-config.yaml included in the clones repository to the install directory
cp ${BASE_DIR_PATH}/install-config.yaml ${BASE_DIR_PATH}/ocp-install

# Update the install-config.yaml with your own pull-secret and ssh key.
# Line 23 should contain the contents of your pull-secret.txt
# Line 24 should contain the contents of your '${BASE_DIR_PATH}/.ssh/id_rsa.pub'
PULL_SECRET="$(cat ${BASE_DIR_PATH}/pull-secret)" 
sed -i "s/pullSecret.*/pullSecret: \"$PULL_SECRET\"/g" ${BASE_DIR_PATH}/ocp-install/install-config.yaml  

SSH_KEY="$(cat ${HOME}/.ssh/id_ed25519.pub)" 
sed -i "s/sshKey.*/pullSecret: \"$SSH_KEY\"/g" ${BASE_DIR_PATH}/ocp-install/install-config.yaml 

# Generate Kubernetes manifest files
${BASE_DIR_PATH}/openshift-install create manifests --dir ${BASE_DIR_PATH}/ocp-install
# A warning is shown about making the control plane nodes schedulable. It is up to you if you want to run workloads on the Control Plane nodes. If you dont want to you can disable this with: sed -i 's/mastersSchedulable: true/mastersSchedulable: false/' ${BASE_DIR_PATH}/ocp-install/manifests/cluster-scheduler-02-config.yml. Make any other custom changes you like to the core Kubernetes manifest files.
# Generate the Ignition config and Kubernetes auth files

${BASE_DIR_PATH}/openshift-install create ignition-configs --dir ${BASE_DIR_PATH}/ocp-install/
# Create a hosting directory to serve the configuration files for the OpenShift booting process

mkdir -p /var/www/html/ocp4
# Copy all generated install files to the new web server directory

cp -R ${BASE_DIR_PATH}/ocp-install/* /var/www/html/ocp4
# Move the Core OS image to the web server directory (later you need to type this path multiple times so it is a good idea to shorten the name)

mv ${BASE_DIR_PATH}/${RHCOS_RAW_FILE_NAME} /var/www/html/ocp4/rhcos
# Change ownership and permissions of the web server directory

chcon -R -t httpd_sys_content_t /var/www/html/ocp4/
chown -R apache: /var/www/html/ocp4/
chmod 755 /var/www/html/ocp4/

# Confirm you can see all files added to the /var/www/html/ocp4/ dir through Apache
curl localhost:8080/ocp4/
