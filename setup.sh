#! /bin/bash -e
set -x

BASE_DIR_PATH="${HOME}/openshift-cluster"

exec ${BASE_DIR_PATH}/scripts/00_Prerequisite.sh
exec ${BASE_DIR_PATH}/scripts/01_BIND_DNS.sh
exec ${BASE_DIR_PATH}/scripts/02_DHCP.sh
exec ${BASE_DIR_PATH}/scripts/03_Apache_Web_Server.sh
exec ${BASE_DIR_PATH}/scripts/04_HAProxy.sh
exec ${BASE_DIR_PATH}/scripts/05_NFS.sh
exec ${BASE_DIR_PATH}/scripts/06_Generate_and_host_Install_files.sh
