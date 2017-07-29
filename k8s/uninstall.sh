#!/bin/bash
set -eu

kubectl -n hackapp delete deployment,service,configmap,secret --all
kubectl -n hackapp-ci delete deployment,service,configmap,secret --all

kubectl delete namespace hackapp hackapp-ci
