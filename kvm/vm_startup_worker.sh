#!/usr/bin/env bash

if [ -z "$1" ]; then
    echo "Usage: $0 <worker-number>"
    exit 1
fi

N="$1"
vm_name="alma9-test-worker-$N"
vm_memory='32768'
vm_cpus='16'
vm_base_disk='/var/lib/libvirt/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2'

ci_user_data='user-data'
ci_network_config='network-configv3'

vm_disk="/var/lib/libvirt/images/rke2-master-AlmaLinux-9-test-worker-$N.qcow2"

qemu-img create -f qcow2 -b "$vm_base_disk" -F qcow2 "$vm_disk" 80G

virt-install \
    --connect qemu:///system \
    --name "$vm_name" \
    --memory "$vm_memory" \
    --machine q35 \
    --vcpus "$vm_cpus" \
    --cpu host-passthrough \
    --import \
    --cloud-init user-data="$ci_user_data" \
    --osinfo name=almalinux9 \
    --disk "$vm_disk" \
    --virt-type kvm \
    --network network=private-net \
    --noautoconsole