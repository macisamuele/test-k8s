#!/bin/bash
set -eu
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd ${DIR}

read -p "Is Kubernetes installed via minikube? [yes/NO]"  is_minikube
if [ "${is_minikube}" == "yes" ]
then
    export K8S_CERTIFICATES='~/.minikube'
fi

# Generate kubernetes-certificates.json
sudo python secret/generate_kubernetes_certificates_minikube.py hackapp kubernetes-certificates
sudo chown $(id -u):$(id -g) secret/kubernetes-certificates.json

# To apply all the configs regardless of the order you can run something similar to
for config_dir in namespace configmap secret persistentvolumeclaim deployment service
do
    # Ensure that kubectl commands are executed on directories with configurations
    [[ ! -z `find ${config_dir}/ -name "*.yaml" -o -name "*.yml" -o -name "*.json"` ]] && \
        kubectl create -f ${config_dir}
done

if [ "${is_minikube}" == "yes" ]
then
    minikube addons enable heapster
    minikube addons enable registry
    minikube dashboard
    echo "Cluster running on $(minikube ip)"
fi

cd -

