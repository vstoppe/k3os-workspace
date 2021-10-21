#!/bin/bash
set -o nounset

### Set the variables
source config
NAME="k3s-m1"
DISK="/mnt/virt/$NAME.qcow2"
DATA_DISK="$VIRT_DIR/${NAME}_data.qcow2"


#### Configure kernel args for installation
SILENT_INST=true # Ensure no questions will be asked
POWER_OFF=true    # Power off after install
CONFIG_URL="http://infraweb.linden.net/$NAME.yaml"
KERNEL_ARGS="k3os.token=$SECRET console=ttyS0 k3os.install.tty=ttyS0 k3os.install.device=/dev/vda k3os.mode=install k3os.install.silent=$SILENT_INST k3os.install.power_off=$POWER_OFF k3os.install.config_url=$CONFIG_URL k3os.install.iso_url=$URL_ISO"


# Cleanup old artefacts
virsh destroy $NAME
virsh undefine $NAME # --remove all-storage would also removes install iso!
virsh vol-delete --pool virtspace ${NAME}.qcow2
virsh vol-delete --pool virtspace ${NAME}_data.qcow2

# Notes:
# * --install: can not take kernel and initrd from fs of libvirt/kvm host, nfs fails too.
# * --boot: removes an '/' of the http-url and fails

virt-install -v \
	--virt-type kvm \
	--name $NAME \
	--install kernel=$KERNEL,initrd="$INITRD",kernel_args="$KERNEL_ARGS"  \
	--vcpu $CPU \
	--memory $(($RAM*1024)) \
	--disk $DISK,bus=virtio,size=$DISK_SIZE,format=qcow2 \
	--disk $DATA_DISK,bus=virtio,size=$DATA_DISK_SIZE,format=qcow2 \
	--disk $ISO,device=cdrom \
	--network network=bridged-network,model=virtio,mac=52:54:00:D0:33:DA \
	--os-variant "ubuntu18.04" \
	--os-type linux \
	--graphics none \
	--boot kernel="$KERNEL_PATH",initrd="$INITRD_PATH",kernel_args="k3os.token=$SECRET console=ttyS0" \
	--console pty,target_type=serial
