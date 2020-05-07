#!/bin/bash

set -e

if [ -f "VERSION_NUMBER.txt" ];
then
    export VERSION_NUMBER=$(cat VERSION_NUMBER.txt)
fi
if [ -z $VERSION_NUMBER ]; then
    export VERSION_NUMBER=3.0.0b
fi

if [ -f "GPF_BUILD.txt" ];
then
    export GPF_BUILD=$(cat GPF_BUILD.txt)
fi
if [ -z $GPF_BUILD ]; then
    export GPF_BUILD=1
fi

echo "VERSION     : ${VERSION_NUMBER}"
echo "GPF_BUILD   : ${GPF_BUILD}"
echo "BUILD_NUMBER: ${BUILD_NUMBER}"

if [ -z $BUILD_NUMBER ]; then
    export TAG="${VERSION_NUMBER}_${GPF_BUILD}"
else
    export TAG="${VERSION_NUMBER}_${GPF_BUILD}_${BUILD_NUMBER}"
fi

echo "TAG         : $TAG"

docker build seqpipe-builder/ -t "seqpipe/seqpipe-builder:${TAG}"

cd seqpipe-gpfjs
./build_gpfjs.sh ${TAG}
cd -

cd seqpipe-gpf
./build_gpf.sh ${TAG}
cd -

((GPF_BUILD+=1))
echo "NEXT_GPF_BUILD=${GPF_BUILD}"

echo $GPF_BUILD > GPF_BUILD.txt
