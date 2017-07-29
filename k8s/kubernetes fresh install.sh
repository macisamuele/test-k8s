#!/bin/bash
set -eu
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd ${DIR}

# Check presence of virtualbox
if [ ! ls /Application/Virtualbox.app ]
then
    echo "Virtualbox is not installed!"
    echo "Please run download and install it from https://www.virtualbox.org/wiki/Downloads"
    exit 1
fi

echo "Verify that homebrew is installed"
if [ ! hash brew ]
then
    echo "homebrew is not installed ... installing it!"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

echo "Verify that kubectl is installed"
if [ ! hash kubectl ]
then
    echo "kubectl is not installed ... installing it!"
    brew install kubectl
fi

echo "Verify that minikube is installed"
if [ ! hash minikube ]
then
    echo "minikube is not installed ... installing it!"
    curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
fi

echo "Starting minikube"
minikube start --memory 4096 --cpus 4 --disk-size 40g --kubernetes-version v1.7.0

echo "Updating ssh fingerprints (~/.ssh/known_hosts)"
ssh-keygen -R $(minikube ip)
ssh-keyscan -H $(minikube ip) >> ~/.ssh/known_hosts

echo "Copying $(dirname $(pwd)) in /home/docker of minikube"
scp -rp -i ~/.minikube/machines/minikube/id_rsa $(dirname $(pwd))/* docker@$(minikube ip):/home/docker/

echo "Building base docker images inside minikube"
minikube ssh ./dockerfiles/build.sh

cd -