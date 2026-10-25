#!/bin/bash
set -euo pipefail

if [[ "$EUID" -ne 0 ]]; then
    echo "Error: This script must be run as root" >&2
    exit 1
fi

mkdir -p /etc/rancher/rke2/
echo """
tls-san:
  - ### REPLACE_WITH_YOUR_DEFAULT_VIP_HERE ###
  - ### REPLACE_WITH_YOUR_PRIVATE_VIP_HERE ###
node-name: ### NODE NAME ###
node-label:
  - "accelerator=no"
  - "nvidia.com/gpu.present=false"
node-ip: ### REPLACE_WITH_MASTER_PRIVATE_IP ###
advertise-address: ### REPLACE_WITH_MASTER_PRIVATE_IP ###
""" > /etc/rancher/rke2/config.yaml

wget -O install.sh https://get.rke2.io/
chmod +x install.sh
./install.sh

dnf install -y keepalived nmap-ncat
mkdir -p /etc/keepalived

tee /etc/keepalived/check-rke2.sh >/dev/null <<'EOF'
#!/bin/sh
set -eu

# The local RKE2 registration port must accept connections.
/usr/bin/nc -z -w 2 127.0.0.1 9345

# The local Kubernetes API must be ready.
# Explicitly use loopback so this never checks a different master via the VIP.
/var/lib/rancher/rke2/bin/kubectl \
    --kubeconfig=/etc/rancher/rke2/rke2.yaml \
    --server=https://127.0.0.1:6443 \
    --request-timeout=2s \
    get --raw=/readyz >/dev/null
EOF

chown root:root /etc/keepalived/check-rke2.sh
chmod 700 /etc/keepalived/check-rke2.sh

tee /etc/keepalived/keepalived.conf >/dev/null <<'EOF'
global_defs {
    router_id RKE2_MASTER_### REPLACE_WITH_MASTER_NUMBER_HERE ###
    enable_script_security
}

vrrp_script check_rke2 {
    script "/etc/keepalived/check-rke2.sh"
    user root
    interval 5
    timeout 6
    fall 2
    rise 2
    weight 0
    init_fail
}

vrrp_instance RKE2_VIP {
    state BACKUP

    # Default-network interface
    interface eth1

    virtual_router_id 51
    priority #### REPLACE_WITH_PRIORITY_HERE ###
    advert_int 1
    nopreempt

    # Permanent default-network IPs
    unicast_src_ip ### REPLACE_WITH_DEFAULT_IP_HERE ###
    unicast_peer {
        ### REPLACE_WITH_OTHER_MASTERS_DEFAULT_IP_HERE ###
        ### ... ###
    }

    # Both addresses belong to the elected master
    virtual_ipaddress {
        ### REPLACE_WITH_YOUR_DEFAULT_VIP_HERE ###/24 dev eth1
        ### REPLACE_WITH_YOUR_PRIVATE_VIP_HERE ###/24 dev eth0
    }

    # Also require the private interface to remain up
    track_interface {
        eth0
    }

    # Periodically refresh ARP announcements on the extra interface
    garp_extra_if all 60

    track_script {
        check_rke2
    }
}
EOF

keepalived --config-test --use-file=/etc/keepalived/keepalived.conf

systemctl enable --now rke2-server
systemctl enable --now keepalived

cp /etc/rancher/rke2/rke2.yaml /home/clouduser/
chown clouduser /home/clouduser/rke2.yaml
export KUBECONFIG=/home/clouduser/rke2.yaml