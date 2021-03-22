#!/bin/bash

export KUBE_NAMESPACE=${KUBE_NAMESPACE}
export KUBE_SERVER=${KUBE_SERVER}
export DEPLOYMENT_NAME=${DEPLOYMENT_NAME:-pttg-ip-hmrc-access-code}

echo
echo "The whole env of deploy.sh is:"
env
echo
echo "====================================="
echo

if [[ -z ${IMAGE_VERSION} ]] ; then
    export VERSION=${DRONE_BUILD_NUMBER}
else
    export VERSION=${IMAGE_VERSION}
fi

echo "deploy ${VERSION} to ${ENVIRONMENT} namespace - using Kube token stored as drone secret"

if [[ ${ENVIRONMENT} == "pr" ]] ; then
    export KUBE_TOKEN=${PTTG_IP_PR}
else
    export KUBE_TOKEN=${PTTG_IP_DEV}
fi

cd kd || exit

kd --insecure-skip-tls-verify \
    -f pod-to-pod-server-certificate.yaml \
    -f networkPolicy.yaml \
    -f deployment.yaml \
    -f service.yaml
