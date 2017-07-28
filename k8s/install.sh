#!/bin/bash
set -eu

# To apply all the configs regardless of the order you can run something similar to
# for config_dir in namespace configmap secret persistentvolumeclaim deployment service
# do
#     # Ensure that kubectl commands are executed on directories with configurations
#     [[ ! -z `find ${config_dir}/ -name "*.yaml" -o -name "*.yml" -o -name "*.json"` ]] && \
#         kubectl create -f ${config_dir}
# done

# Generate kubernetes-certificates.yaml
python secret/generate_kubernetes_certificates_minikube.py hackapp kubernetes-certificates

# Generate namespaces (hackapp and hackapp-ci)
kubectl create -f namespace/

# Generate secret
kubectl create -f secret/

# Generate deployment (NOTE: It's wanted the exclusion of deployment/gitlab-runner.yaml)
kubectl create -f deployment/gitlab.yaml -f deployment/tutum-hello-world.yaml

# Generate service
kubectl create -f service/

echo """
Please update deployment/gitlab-runner.yaml with the token provided by gitlab ($(minikube service -n hackapp gitlab --url | head -n 1))
and then run ``kubectl create -f configmap/gitlab-runner.yaml -f deployment/gitlab-runner.yaml``
"""