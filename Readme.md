# Abstract

This repo contains the files for setting up my delopment environment for k3os in kvm. K3os is a appliance os for k3s/Kubernetes. For more information refer the their [GitHub Page](https://github.com/rancher/k3os) The shell scripts spin up VMs for one master node and 1..N worker nodes.

# Preparation

Before you can use this script you need:

* working kvm hypervisor
* local webserver serving:
******  * k3os-amd64.iso
  * k3s-****.yaml configs

# Configuration

All environment ist configured in the config file. To start copy

`cp config.example config`

and adjust it to your needs.

You also need to provide libvirt the files:

* k3os-initrd-amd64
* k3os-vmlinuz-amd64
* k3os-amd64.iso

The location for these files are all defined in the config file. You can download the files from the [releases page](https://github.com/rancher/k3os/releases) of K3os below "Assets".

In the config file you need to define the path for kernel and initrd two times. This is because it enables the administration of the libvirt-/kvm-host from a remote machine. So far I haven't found a better solution. Let me know if you know!

Path on client machine:

* INITRD="./assets/k3os-initrd-amd64" 
* KERNEL="./assets/k3os-vmlinuz-amd64"

Local path on libvirt-/kvm-host for --boot parameter:

* INITRD_PATH="/mnt/images/k3os-initrd-amd64" # not found
* KERNEL_PATH="/mnt/images/k3os-vmlinuz-amd64"

Change it to your needs.

One part of the configuration is given to the K3os VMs by the yaml file. The other part is configured by the cmdline parameter of the vm.

# Installation of the environment

Install the master:

`./k3s-m1-install.sh`

This installs the master vm and leaves you at the login prompt.

Before installing the worker you need to get server token from the master:

`cat /var/lib/rancher/k3s/server/token`

place it in the "TOKEN" variable in the config file.

Now you can install the worker. You just have to append the hostname of the new worker behind the install script. Example:

`./k3s-worker-install.sh k3s-w1`

Now repeat the steps for adjusting the k3s-m1 for every new worker.

# Connect to the cluster

`scp rancher@k3s-m1:/etc/rancher/k3s/k3s.yaml ~/.kube/k3s.yaml`

Rename the inherited server url in k3s.yaml from 127.0.1 to the real hostname.

`export KUBECONFIG=~/.kube/config:~/someotherconfig`

`kubectl config view --flatten > ~/.kube/config`
