#!/bin/bash
if [ -z "$1" ]; then
  echo "Usage: $0 <worker-number>"
  exit 1
fi

WORKER_NUM="$1"

mkdir -p /etc/rancher/rke2/
cat <<EOF > /etc/rancher/rke2/config.yaml
server: https://### MASTER_IP ###:9345
token: ### REPLACE_WITH_YOUR_TOKEN_HERE ###
node-name: worker-${WORKER_NUM}
EOF

curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -
systemctl enable rke2-agent.service
systemctl start rke2-agent.service