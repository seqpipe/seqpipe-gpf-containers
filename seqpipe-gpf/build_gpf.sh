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

if [ ! -d gpf ];
then
    git clone git@github.com:iossifovlab/gpf.git
fi

cd gpf

git clean --force
git checkout .
git pull
git checkout $BRANCH
git pull

cd -


docker build . -t seqpipe/seqpipe-gpf:${TAG} --build-arg VERSION_TAG=${TAG}
docker build . -t seqpipe/seqpipe-gpf:latest --build-arg VERSION_TAG=${TAG}

cd gpf
git tag -f ${TAG}
cd -
