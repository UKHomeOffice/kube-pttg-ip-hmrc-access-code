#!/bin/bash

export KUBE_NAMESPACE=${KUBE_NAMESPACE}
export KUBE_SERVER=${KUBE_SERVER}
export DEPLOYMENT_NAME=${DEPLOYMENT_NAME:-pttg-ip-hmrc-access-code}

if [[ -z ${IMAGE_VERSION} ]] ; then
    echo "promoting build [build-${DRONE_BUILD_PARENT}] (the image built in the promoted job)"
    export VERSION=build-${DRONE_BUILD_PARENT}
else
    echo "promoting build [IMAGE_VERSION] (specified in the 'drone build promote' command)"
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
