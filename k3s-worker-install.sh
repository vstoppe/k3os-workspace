#!/bin/bash
set -o nounset

### Set the variables
source config
NAME=$1
DISK="$VIRT_DIR/$NAME.qcow2"
DATA_DISK="$VIRT_DIR/${NAME}_data.qcow2"


#### Configure kernel args for installation
SILENT_INST=true # Ensure no questions will be asked
POWER_OFF=true    # Power off after install
#KERNEL_ARGS="k3os.install.config_url=$URL_WORKER_CONFIG k3os.token=$TOKEN hostname=$NAME console=ttyS0 k3os.install.tty=ttyS0 k3os.install.device=/dev/vda k3os.mode=install k3os.install.silent=$SILENT_INST k3os.install.power_off=$POWER_OFF k3os.install.iso_url=$URL_ISO"
KERNEL_ARGS="k3os.install.config_url=$URL_WORKER_CONFIG \
	console=ttyS0 \
	hostname=$NAME \
	k3os.install.device=/dev/vda \
	k3os.install.iso_url=$URL_ISO \
	k3os.install.power_off=$POWER_OFF \
	k3os.install.silent=$SILENT_INST \
	k3os.install.tty=ttyS0 \
	k3os.mode=install \
	k3os.token=$TOKEN \
	"


# Cleanup old artefacts
virsh destroy $NAME
virsh undefine $NAME # --remove all-storage would also removes install iso!
virsh vol-delete --pool virtspace ${NAME}.qcow2
virsh vol-delete --pool virtspace ${NAME}_data.qcow2


virt-install -v \
	--virt-type kvm \
	--name $NAME \
	--install kernel=$KERNEL,initrd="$INITRD",kernel_args="$KERNEL_ARGS"  \
	--vcpus $CPU \
	--memory $(($RAM*1024)) \
	--disk $DISK,bus=virtio,size=$DISK_SIZE,format=qcow2 \
	--disk $DATA_DISK,bus=virtio,size=$DATA_DISK_SIZE,format=qcow2 \
	--disk $ISO,device=cdrom \
	--network network=bridged-network,model=virtio \
	--os-type linux \
	--os-variant ubuntu18.04 \
	--graphics none \
	--boot kernel="$KERNEL_PATH",initrd="$INITRD_PATH",kernel_args="k3os.token=$SECRET console=ttyS0" \
	--console pty,target_type=serial
