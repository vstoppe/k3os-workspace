#!/bin/bash
set -o nounset

### Set the variables
source config
NAME="k3s-m1"
DISK="/mnt/virt/$NAME.qcow2"
RAM=4 # in GB


#### Configure kernel args for installation
SILENT_INST=true # Ensure no questions will be asked
POWER_OFF=true    # Power off after install
CONFIG_URL="http://infraweb.lindenbox.de/$NAME.yaml"
KERNEL_ARGS="k3os.token=$SECRET console=ttyS0 k3os.install.tty=ttyS0 k3os.install.device=/dev/vda k3os.mode=install k3os.install.silent=$SILENT_INST k3os.install.power_off=$POWER_OFF k3os.install.config_url=$CONFIG_URL k3os.install.iso_url=$URL_ISO"


# Cleanup old artefacts
virsh destroy $NAME
virsh undefine $NAME
rm -f $VIRT_DIR/$NAME.qcow2


virt-install -v \
	--virt-type kvm \
	--name $NAME \
	--memory $(($RAM*1024)) \
	--disk $DISK,bus=virtio,size=$DISK_SIZE,format=qcow2 \
	--cdrom $ISO \
	--boot kernel=$KERNEL,initrd="$INITRD",kernel_args="$KERNEL_ARGS"  \
	--network=bridge,model=virtio,mac=52:54:00:D0:33:DA \
	--os-type linux \
	--os-variant ubuntu20.04 \
	--graphics none \
	--console pty,target_type=serial
