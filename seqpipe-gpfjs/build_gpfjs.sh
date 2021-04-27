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
    export WD=${WORKSPACE}/seqpipe-gpfjs
fi

echo "WORKSPACE=${WORKSPACE}"
echo "WD=${WD}"

echo "[package_gpfjs] going to remove node_modules..."

# clean node_modules
docker run --rm \
    -v ${WD}:/work \
    busybox:latest \
    /bin/sh -c "rm -rf /work/gpfjs/node_modules && rm -rf /work/gpfjs/package-lock.json"

# clean gpfjs distribution
docker run --rm \
    -v ${WD}:/work \
    busybox:latest \
    /bin/sh -c "rm -rf /work/gpfjs/dist"

# if [ ! -d gpfjs ];
# then
#     git clone git@github.com:iossifovlab/gpfjs.git
# fi

# cd gpfjs
# git clean --force
# git checkout .
# git pull
# git checkout $BRANCH
# git pull
# cd -

# "seqpipe/seqpipe-builder:3.2.8.165" \

chmod 0777 -R ${WD}/gpfjs

docker run \
    -v "${WD}:/work" \
    "${REGISTRY}/seqpipe-builder:${TAG}" \
    /work/package_gpfjs.sh ${TAG}


docker build . -t ${REGISTRY}/seqpipe-gpfjs:${TAG} --build-arg VERSION_TAG=${TAG}
docker build . -t ${REGISTRY}/seqpipe-gpfjs:latest --build-arg VERSION_TAG=${TAG}
