#! /bin/bash -e
set -x

BASE_DIR_PATH="${HOME}/openshift-cluster"

EXTERNAL_NIC_NAME="ens160"
INTERNAL_NIC_NAME="ens192"

OPENSHIFT_CLIENT_LINUX_DOWNLOAD_URL="https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.5.6/openshift-client-linux-4.5.6.tar.gz"
OPENSHIFT_INSTALL_LINUX_DOWNLOAD_URL="https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.5.6/openshift-install-linux-4.5.6.tar.gz"


OPENSHIFT_CLIENT_LINUX_TAR_FILE_NAME="openshift-client-linux.tar.gz"
OPENSHIFT_INSTALL_LINUX_TAR_FILE_NAME="openshift-install-linux.tar.gz"


wget -c "${OPENSHIFT_CLIENT_LINUX_DOWNLOAD_URL}" -P "${BASE_DIR_PATH}" -O "${OPENSHIFT_CLIENT_LINUX_TAR_FILE_NAME}" -q --show-progress
wget -c "${OPENSHIFT_INSTALL_LINUX_DOWNLOAD_URL}" -P "${BASE_DIR_PATH}" -O "${OPENSHIFT_INSTALL_LINUX_TAR_FILE_NAME}" -q --show-progress

cd ${BASE_DIR_PATH}
# Extract Client tools and copy them to /usr/local/bin
tar xvf "$(${BASE_DIR_PATH}/${OPENSHIFT_CLIENT_LINUX_TAR_FILE_NAME})"
mv oc kubectl /usr/local/bin

# Confirm Client Tools are working
echo $(oc version)
echo $(kubectl version)

# Extract the OpenShift Installer
tar xvf "$(${BASE_DIR_PATH}/${OPENSHIFT_INSTALL_LINUX_TAR_FILE_NAME})"

# ${RHCOS_RAW_FILE_NAME}

cat <<EOT >> ${HOME}/.vimrc
syntax on
set nu et ai sts=0 ts=2 sw=2 list hls
EOT

echo "export OC_EDITOR=\"vim\"" >> ${HOME}/.bash_profile
echo "export KUBE_EDITOR=\"vim\"" >> ${HOME}/.bash_profile
source ${HOME}/.bash_profile


# cat <<EOT >> /etc/resolv.conf
# # Generated by NetworkManager
# search localdomain ocp.lan
# nameserver 172.16.218.2
# nameserver 127.0.0.1
# EOT

nmcli con mod ${INTERNAL_NIC_NAME} ipv4.addresses 192.168.22.10/24
# nmcli con mod ${INTERNAL_NIC_NAME} ipv4.gateway 192.168.2.1
nmcli con mod ${INTERNAL_NIC_NAME} ipv4.dns "127.0.0.1"
nmcli con mod ${INTERNAL_NIC_NAME} ipv4.method manual
nmcli con mod ${INTERNAL_NIC_NAME} ipv4.dns-search "ocp.lan"
systemctl restart NetworkManager

nmcli connection modify ${EXTERNAL_NIC_NAME} connection.zone external
nmcli connection modify ${INTERNAL_NIC_NAME} connection.zone internal

firewall-cmd --get-active-zones
firewall-cmd --zone=external --add-masquerade --permanent
firewall-cmd --zone=internal --add-masquerade --permanent
firewall-cmd --reload

echo $(firewall-cmd --list-all --zone=internal)
echo $(firewall-cmd --list-all --zone=external)
echo $(cat /proc/sys/net/ipv4/ip_forward)