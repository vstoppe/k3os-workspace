#!/bin/bash
set -o nounset

### Set the variables
source config
source .master
NAME=$1
DISK="$VIRT_DIR/$NAME.qcow2"
DATA_DISK="$VIRT_DIR/${NAME}_data.qcow2"


DOMAIN="fritz.box"


#### Configure kernel args for installation
SILENT_INST=true # Ensure no questions will be asked
POWER_OFF=true    # Power off after install
KERNEL_INSTALL_ARGS="\
	console=ttyS0 \
	hostname=$NAME \
	k3os.install.device=/dev/vda \
	k3os.install.iso_url=$URL_ISO \
	k3os.install.power_off=$POWER_OFF \
	k3os.install.silent=$SILENT_INST \
	k3os.install.tty=ttyS0 \
	k3os.mode=install \
	k3os.token=$TOKEN \
  k3os.password="$RANCHER_PASSWORD" \
  k3os.server_url="https://${master_name}.${DOMAIN}:6443" \
"


# Cleanup old artefacts
virsh destroy $NAME
virsh undefine $NAME # --remove all-storage would also removes install iso!
virsh vol-delete --pool virtspace ${NAME}.qcow2
virsh vol-delete --pool virtspace ${NAME}_data.qcow2


virt-install -v \
	--virt-type kvm \
	--name $NAME \
	--install kernel=$KERNEL,initrd="$INITRD",kernel_args="$KERNEL_INSTALL_ARGS"  \
	--vcpus $CPU \
	--memory $(($RAM*1024)) \
	--disk $DISK,bus=virtio,size=$DISK_SIZE,format=qcow2 \
	--disk $DATA_DISK,bus=virtio,size=$DATA_DISK_SIZE,format=qcow2 \
	--disk $ISO,device=cdrom \
	--network network=bridged-network,model=virtio \
	--os-type linux \
	--os-variant ubuntu18.04 \
	--graphics none \
	--boot kernel="$KERNEL_PATH",initrd="$INITRD_PATH",kernel_args="$KERNEL_BOOT_ARGS" \
	--console pty,target_type=serial
