#!/bin/bash
set -o nounset



### Set the variables
source config
NAME=$1
DISK="$VIRT_DIR/$NAME.qcow2"

#### Configure kernel args for installation
SILENT_INST=true # Ensure no questions will be asked
POWER_OFF=true    # Power off after install
KERNEL_ARGS="k3os.install.config_url=$URL_WORKER_CONFIG k3os.token=$TOKEN hostname=$NAME console=ttyS0 k3os.install.tty=ttyS0 k3os.install.device=/dev/vda k3os.mode=install k3os.install.silent=$SILENT_INST k3os.install.power_off=$POWER_OFF k3os.install.iso_url=$URL_ISO"


# Cleanup old artefacts
virsh destroy $NAME
virsh undefine $NAME
rm -f $VIRT_DIR/$NAME.qcow2

virt-install -v \
	--virt-type kvm \
	--name $NAME \
	--boot hd,cdrom \
	--vcpus=$WORKER_CPU \
	--memory $(($WORKER_RAM*1024)) \
	--disk $DISK,bus=virtio,size=$DISK_SIZE,format=qcow2 \
	--cdrom $ISO \
	--boot kernel=$KERNEL,initrd="$INITRD",kernel_args="$KERNEL_ARGS"  \
	--network=bridge,model=virtio \
	--os-type linux \
	--os-variant ubuntu20.04 \
	--graphics none \
	--console pty,target_type=serial
