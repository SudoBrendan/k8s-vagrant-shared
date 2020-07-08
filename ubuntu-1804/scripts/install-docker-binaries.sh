#!/bin/bash
################################################################################
#
# install-docker-binaries.sh: Install and configure a specific release of
#   docker.
#
# Usage:
#   config.vm.provision "shell", path: "https://raw.githubusercontent.com/SudoBrendan/k8s-vagrant-shared/master/ubuntu-1804/scripts/install-docker-binaries.sh", env: {"DOCKER_VERSION" => "19.03.11"}
#
################################################################################

set -e

echo "=============================="
echo "DOCKER"
echo "=============================="

apt-get install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update -y
apt-get install -y \
    docker-ce="5:${DOCKER_VERSION}~3-0~ubuntu-$(lsb_release -cs)" \
    docker-ce-cli="5:${DOCKER_VERSION}~3-0~ubuntu-$(lsb_release -cs)"

apt-mark hold docker-ce docker-ce-cli

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d
usermod -aG docker vagrant

systemctl daemon-reload
systemctl enable docker
systemctl restart docker

