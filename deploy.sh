#!/bin/bash

export KUBE_NAMESPACE=${KUBE_NAMESPACE}
export KUBE_SERVER=${KUBE_SERVER}

if [[ -z ${VERSION} ]] ; then
    export VERSION=${IMAGE_VERSION}
fi

if [[ ${ENVIRONMENT} == "pr" ]] ; then
    echo "deploy ${VERSION} to pr namespace, using PTTG_IP_PR drone secret"
    export KUBE_TOKEN=${PTTG_IP_PR}
    # An empty "downscaler/uptime" annotation is ignored
    export UPTIME_SCHEDULE=''
else
    if [[ ${ENVIRONMENT} == "test" ]] ; then
        echo "deploy ${VERSION} to test namespace, using PTTG_IP_TEST drone secret"
        export KUBE_TOKEN=${PTTG_IP_TEST}
    else
        echo "deploy ${VERSION} to dev namespace, using PTTG_IP_DEV drone secret"
        export KUBE_TOKEN=${PTTG_IP_DEV}
    fi
    # Scale down all pods every night in non-prod.
    # Using the same from/to time on annotation "downscaler/uptime" scales down at that time but never scales up.
    export UPTIME_SCHEDULE='Mon-Sun 20:00-20:00 Europe/London'
fi

if [[ -z ${KUBE_TOKEN} ]] ; then
    echo "Failed to find a value for KUBE_TOKEN - exiting"
    exit -1
fi

cd kd

kd --insecure-skip-tls-verify \
    -f networkPolicy.yaml \
    -f deployment.yaml \
    -f service.yaml
