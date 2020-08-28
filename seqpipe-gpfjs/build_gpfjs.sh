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


if [ -z $WORKSPACE ];
then
    export WORKSPACE=`pwd`
fi

echo "WORKSPACE=${WORKSPACE}"

if [ ! -d gpfjs ];
then
    git clone git@github.com:iossifovlab/gpfjs.git
fi


export PRODUCTION_TAG="3.0.0.80"
echo "Production build star: ${PRODUCTION_TAG}"
cd gpfjs
git clean --force
git checkout master
git checkout "${PRODUCTION_TAG}"
cd -

docker run \
    -v "${WORKSPACE}:/work" \
    --user 1000:1000 \
    "seqpipe/seqpipe-builder:${PRODUCTION_TAG}" \
    /work/package_gpfjs_gpf.sh ${PRODUCTION_TAG}


cd gpfjs

git clean --force
git checkout $BRANCH
git checkout .
git pull

cd -

# docker pull seqpipe/seqpipe-builder:${TAG}

docker run \
    -v "${WORKSPACE}:/work" \
    --user 1000:1000 \
    "seqpipe/seqpipe-builder:${TAG}" \
    /work/package_gpfjs.sh ${TAG}


docker build . -t seqpipe/seqpipe-gpfjs:${TAG} --build-arg VERSION_TAG=${TAG}
docker build . -t seqpipe/seqpipe-gpfjs:latest --build-arg VERSION_TAG=${TAG}

cd gpfjs
git tag -f ${TAG}
cd -
