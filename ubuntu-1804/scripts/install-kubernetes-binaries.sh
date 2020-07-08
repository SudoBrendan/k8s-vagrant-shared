#!/bin/bash
################################################################################
#
# install-kubernetes-binaries.sh: Install a specific release of Kubernetes
#   binaries.
#
# Usage:
#   config.vm.provision "shell", path: "https://raw.githubusercontent.com/SudoBrendan/k8s-vagrant-shared/master/ubuntu-1804/scripts/install-kubernetes-binaries.sh", env: {"K8S_VERSION" => "1.18.4"}
#
################################################################################

set -e

echo "=============================="
echo "KUBERNETES BINARIES"
echo "=============================="

# Network bridge
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system >/dev/null


# Disable SWAP
sed -i '/swap/d' /etc/fstab
swapoff -a


# Prereq
apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
ls -ltr /etc/apt/sources.list.d/kubernetes.list
apt-get update


# Binaries
apt-get install -y \
    kubelet="${K8S_VERSION}-00" \
    kubeadm="${K8S_VERSION}-00" \
    kubectl="${K8S_VERSION}-00"
apt-mark hold kubelet kubeadm kubectl


systemctl enable kubelet
systemctl start kubelet

