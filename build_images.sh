#!/bin/bash

set -e

if [ -f "VERSION_NUMBER.txt" ];
then
    export VERSION_NUMBER=$(cat VERSION_NUMBER.txt)
fi
if [ -z $VERSION_NUMBER ]; then
    export VERSION_NUMBER=3.0.0b
fi

if [ -f "BUILD_NUMBER.txt" ];
then
    export BUILD_NUMBER=$(cat BUILD_NUMBER.txt)
fi
if [ -z $BUILD_NUMBER ]; then
    export BUILD_NUMBER=1
fi

echo "VERSION     : ${VERSION_NUMBER}"
echo "BUILD_NUMBER: ${BUILD_NUMBER}"

export TAG="${VERSION_NUMBER}${BUILD_NUMBER}"

echo "TAG         : $TAG"

docker build seqpipe-builder/ -t "seqpipe/seqpipe-builder:${TAG}"

cd seqpipe-gpfjs
./build_gpfjs.sh ${TAG}
cd -


((BUILD_NUMBER+=1))
echo "NEXT_BUILD_NUMBER=${BUILD_NUMBER}"

echo $BUILD_NUMBER > BUILD_NUMBER.txt
