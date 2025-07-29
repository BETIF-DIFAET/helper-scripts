#!/bin/bash
mkdir -p /etc/rancher/rke2/
echo """
tls-san:
  - ### MASTER_IP ####
  - ### ADDITIONAL_IPS_IF_NEEDED ###
""" > /etc/rancher/rke2/config.yaml
curl -sfL https://get.rke2.io | sh -
systemctl enable rke2-server.service
systemctl start rke2-server.service
sudo cp /etc/rancher/rke2/rke2.yaml /home/clouduser/
sudo chown clouduser /home/clouduser/rke2.yaml
export KUBECONFIG=/home/clouduser/rke2.yaml