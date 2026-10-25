#!/bin/bash
set -euo pipefail

if [[ "$EUID" -ne 0 ]]; then
    echo "Error: This script must be run as root" >&2
    exit 1
fi

if [ -z "$1" ]; then
  echo "Usage: $0 <worker-number>"
  exit 1
fi

WORKER_NUM="$1"

mkdir -p /etc/rancher/rke2/
cat <<EOF > /etc/rancher/rke2/config.yaml
server: https://### MASTER_PRIVATE_VIP ###:9345
token: ### REPLACE_WITH_YOUR_TOKEN_HERE ###
node-name: worker-${WORKER_NUM}
node-ip: ### REPLACE_WITH_WORKER_PRIVATE_IP ###
EOF

wget -O install.sh https://get.rke2.io/
chmod +x install.sh
./install.sh

systemctl enable rke2-agent.service
systemctl start rke2-agent.service