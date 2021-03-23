#!/bin/bash

set -e

if [ "$1" ]; then
    export TAG=$1
    echo "TAG=${TAG}"
else
    echo 'ERROR: requires a non-empty version TAG'
    exit 1
fi

if [ "$2" ]; then
    export BRANCH=$2
    echo "BRANCH=${BRANCH}"
else
    echo 'ERROR: requires a non-empty BRANCH'
    exit 1
fi

if [ "$3" ]; then
    export REGISTRY=$3
    echo "REGISTRY=${REGISTRY}"
else
    echo 'ERROR: requires a non-empty REGISTRY'
    exit 1
fi

if [ -z $WORKSPACE ];
then
    export WD=`pwd`
else
    export WD=${WORKSPACE}/seqpipe-gpf-full
fi

echo "WORKSPACE=${WORKSPACE}"
echo "WD=${WD}"
export seqpipe_gpf="${REGISTRY}/seqpipe-gpf:latest"

sed \
    s/":REGISTRY:/${REGISTRY}/"g \
    Dockerfile  > Dockerfile.build


docker build . -f Dockerfile.build \
    -t ${REGISTRY}/seqpipe-gpf-full:${TAG} \
    --build-arg VERSION_TAG=${TAG}

docker build . -f Dockerfile.build \
    -t ${REGISTRY}/seqpipe-gpf-full:latest \
    --build-arg VERSION_TAG=${TAG}

