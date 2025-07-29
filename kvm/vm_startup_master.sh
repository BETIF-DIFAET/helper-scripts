#!/usr/bin/env bash

vm_name='alma9-test-master'
vm_memory='32768'
vm_cpus='16'
vm_disk='/var/lib/libvirt/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2'

ci_user_data='user-data'
ci_network_config='network-configv3'
qemu-img create -f qcow2 -b /var/lib/libvirt/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2 -F qcow2 /var/lib/libvirt/images/rke2-master-AlmaLinux-9-test-master.qcow2 80G
vm_disk='/var/lib/libvirt/images/rke2-master-AlmaLinux-9-test-master.qcow2'

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
    --network network=default \
    --noautoconsole