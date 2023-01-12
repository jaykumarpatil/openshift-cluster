#! /bin/bash -e
set -x

BASE_DIR_PATH="${HOME}/openshift-cluster"

bash ${BASE_DIR_PATH}/scripts/00_Prerequisite.sh
bash ${BASE_DIR_PATH}/scripts/01_BIND_DNS.sh
bash ${BASE_DIR_PATH}/scripts/02_DHCP.sh
bash ${BASE_DIR_PATH}/scripts/03_Apache_Web_Server.sh
bash ${BASE_DIR_PATH}/scripts/04_HAProxy.sh
bash ${BASE_DIR_PATH}/scripts/05_NFS.sh
bash ${BASE_DIR_PATH}/scripts/06_Generate_and_host_Install_files.sh
