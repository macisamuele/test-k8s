#!/bin/bash
set -eu

export SINGLE_NODE_CLUSTER=yes
export DOCKER_VERSION=17.06.0~ce-0~ubuntu
export KUBECTL_VERSION=v1.7.3
export KUBELET_VERSION=1.7.3-01
export KUBEADM_VERSION=1.7.3-01

if [ "$(id -u)" == "0" ]
then
    echo Run the script as normal user
    exit 1
fi

if ! hash docker 2> /dev/null
then
    echo "Installing docker"
    sudo mkdir -p /etc/docker
    sudo bash -c "echo '{\"storage-driver\": \"overlay2\"}' > /etc/docker/daemon.json"
    sudo apt-get update && \
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && \
    sudo apt-key fingerprint 0EBFCD88 | grep --silent -E "^\s+Key fingerprint = 9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88\s*$" || echo "Wrong apt-key fingerprint ... abort build" && \
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
    sudo apt-get update && \
    sudo apt-get install -y docker-ce=${DOCKER_VERSION}
fi

if ! hash kubectl 2> /dev/null
then
    echo "Installing kubectl"
    curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    sudo mv ./kubectl /usr/local/bin/kubectl
    echo "source <(kubectl completion bash)" >> $HOME/.bash_profile
fi

if ! hash kubeadm 2> /dev/null
then
    echo "Installing kubeadm adn kubelet"
    sudo apt-get update && \
    sudo apt-get install -y apt-transport-https && \
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
    sudo bash -c 'echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list' && \
    sudo apt-get update && \
    sudo apt-get install -y kubelet=${KUBELET_VERSION} kubeadm=${KUBEADM_VERSION}
fi

echo "Init process inspired by https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/"

echo "Initializing kubeadm"
sudo kubeadm init

echo "Set default kubernetes configuration for kubectl"
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

if [ "${SINGLE_NODE_CLUSTER}" == "yes" ]
then
    echo "Allow kubernetes master to run pods (single node cluster)"
    kubectl taint nodes --all node-role.kubernetes.io/master-
fi

echo "Set weawe network"
kubectl apply -f https://git.io/weave-kube-1.6
