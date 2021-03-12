#!/bin/bash

set -e


if [ "$1" ]; then
    export BRANCH=$1
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

# clean node_modules
docker run -d --rm \
    -v ${WORKSPACE}/seqpipe-gpfjs:/work \
    busybox:latest \
    /bin/sh -c "rm -rf /work/gpfjs/node_modules && rm -rf /work/gpfjs/package-lock.json"

# GPF
cd seqpipe-gpf

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

cd $WORKSPACE

# GPFJS

cd seqpipe-gpfjs

if [ ! -d gpfjs ];
then
    git clone git@github.com:iossifovlab/gpfjs.git
fi

cd gpfjs
git clean --force
git checkout .
git pull
git checkout $BRANCH
git pull
cd -

cd $WORKSPACE
