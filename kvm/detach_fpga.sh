modprobe vfio
modprobe vfio_pci

echo 0000:01:00.0 > /sys/bus/pci/drivers/xclmgmt/unbind
echo 0000:01:00.1 > /sys/bus/pci/drivers/xocl/unbind

echo vfio-pci > /sys/bus/pci/devices/0000:01:00.0/driver_override
echo vfio-pci > /sys/bus/pci/devices/0000:01:00.1/driver_override

echo 0000:01:00.0 > /sys/bus/pci/drivers_probe
echo 0000:01:00.1 > /sys/bus/pci/drivers_probe

lspci -k -s 01:00.0
lspci -k -s 01:00.1

echo 0000:25:00.0 > /sys/bus/pci/drivers/xclmgmt/unbind
echo 0000:25:00.1 > /sys/bus/pci/drivers/xocl/unbind

echo vfio-pci > /sys/bus/pci/devices/0000:25:00.0/driver_override
echo vfio-pci > /sys/bus/pci/devices/0000:25:00.1/driver_override

echo 0000:25:00.0 > /sys/bus/pci/drivers_probe
echo 0000:25:00.1 > /sys/bus/pci/drivers_probe

lspci -k -s 25:00.0
lspci -k -s 25:00.1

echo 0000:e1:00.0 > /sys/bus/pci/drivers/xclmgmt/unbind
echo 0000:e1:00.1 > /sys/bus/pci/drivers/xocl/unbind

echo vfio-pci > /sys/bus/pci/devices/0000:e1:00.0/driver_override
echo vfio-pci > /sys/bus/pci/devices/0000:e1:00.1/driver_override

echo 0000:e1:00.0 > /sys/bus/pci/drivers_probe
echo 0000:e1:00.1 > /sys/bus/pci/drivers_probe

lspci -k -s e1:00.0
lspci -k -s e1:00.1

