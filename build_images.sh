#!/bin/bash

set -e

if [ -f "VERSION_NUMBER.txt" ];
then
    export VERSION_NUMBER=$(cat VERSION_NUMBER.txt)
fi
if [ -z $VERSION_NUMBER ]; then
    export VERSION_NUMBER=3.0.0.beta
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
    export TAG="${VERSION_NUMBER}${GPF_BUILD}"
else
    export TAG="${VERSION_NUMBER}${GPF_BUILD}_${BUILD_NUMBER}"
fi

echo "TAG         : $TAG"

docker build seqpipe-builder/ -t "seqpipe/seqpipe-builder:${TAG}"
docker build seqpipe-builder/ -t "seqpipe/seqpipe-builder:latest"

cd seqpipe-gpfjs
./build_gpfjs.sh ${TAG}
cd -

cd seqpipe-gpf
./build_gpf.sh ${TAG}
cd -

docker push seqpipe/seqpipe-builder:${TAG}
docker push seqpipe/seqpipe-builder:latest

docker push seqpipe/seqpipe-gpfjs:${TAG}
docker push seqpipe/seqpipe-gpfjs:latest

docker push seqpipe/seqpipe-gpf:${TAG}
docker push seqpipe/seqpipe-gpf:latest


cd seqpipe-gpfjs/gpfjs
git tag -f ${TAG}
git push origin --tags
cd -

cd seqpipe-gpf/gpf
git tag -f ${TAG}
git push origin --tags
cd -

git tag -f ${TAG}

((GPF_BUILD+=1))
echo "NEXT_GPF_BUILD=${GPF_BUILD}"

echo $GPF_BUILD > GPF_BUILD.txt

git add GPF_BUILD.txt
git commit -m "new build done"
git push origin --tags
