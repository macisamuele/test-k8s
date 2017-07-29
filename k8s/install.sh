#!/bin/bash
set -eu
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd ${DIR}

# Generate kubernetes-certificates.json
python secret/generate_kubernetes_certificates_minikube.py hackapp kubernetes-certificates

# To apply all the configs regardless of the order you can run something similar to
for config_dir in namespace configmap secret persistentvolumeclaim deployment service
do
    # Ensure that kubectl commands are executed on directories with configurations
    [[ ! -z `find ${config_dir}/ -name "*.yaml" -o -name "*.yml" -o -name "*.json"` ]] && \
        kubectl create -f ${config_dir}
done


minikube addons enable heapster
minikube addons enable registry

minikube dashboard

echo "Cluster running on $(minikube ip)"

cd -

