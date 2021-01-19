#!/bin/bash

set -e

if [ -f "VERSION_NUMBER.txt" ];
then
    export VERSION_NUMBER=$(cat VERSION_NUMBER.txt)
fi
if [ -z $VERSION_NUMBER ]; then
    echo "Version number not found..."
    exit 1
fi

if [ -f "GPF_BUILD.txt" ];
then
    export GPF_BUILD=$(cat GPF_BUILD.txt)
fi
if [ -z $GPF_BUILD ]; then
    export GPF_BUILD=0
fi

((GPF_BUILD+=1))

# export BRANCH="master"
export BRANCH="release-3.3"


echo "VERSION     : ${VERSION_NUMBER}"
echo "GPF_BUILD   : ${GPF_BUILD}"
echo "BUILD_NUMBER: ${BUILD_NUMBER}"

if [ -z $BUILD_NUMBER ]; then
    export TAG="${VERSION_NUMBER}.${GPF_BUILD}"
else
    export TAG="${VERSION_NUMBER}.${GPF_BUILD}_${BUILD_NUMBER}"
fi

echo "TAG         : $TAG"
echo "BRANCH      : $BRANCH"

docker build seqpipe-builder/ -t "seqpipe/seqpipe-builder:${TAG}"
docker build seqpipe-builder/ -t "seqpipe/seqpipe-builder:latest"

cd seqpipe-http
./build_http.sh ${TAG} ${BRANCH}
cd -

rm -f seqpipe-gpfjs/gpfjs-dist-*.tar.gz
rm -f seqpipe-gpf-full/gpfjs-dist-*.tar.gz

cd seqpipe-gpfjs
./build_gpfjs.sh ${TAG} ${BRANCH}
cd -
cp seqpipe-gpfjs/gpfjs-dist-default-${TAG}.tar.gz seqpipe-gpf-full

cd seqpipe-gpf
./build_gpf.sh ${TAG} ${BRANCH}
cd -

cd seqpipe-gpf-full
./build_gpf_full.sh ${TAG} ${BRANCH}
cd -

for repo in seqpipe-builder seqpipe-gpfjs seqpipe-gpf seqpipe-gpf-full seqpipe-http; do
    echo "pushing docker image: ${repo}:${TAG}"
    docker push seqpipe/${repo}:${TAG}
    docker push seqpipe/${repo}:latest
done


cd seqpipe-gpfjs/gpfjs
git tag -f ${TAG}
git push origin --tags
cd -

cd seqpipe-gpf/gpf
git tag -f ${TAG}
git push origin --tags
cd -

git tag -f ${TAG}
echo $GPF_BUILD > GPF_BUILD.txt

git add GPF_BUILD.txt
git commit -m "new build done"
git push origin --tags

echo $GPF_BUILD > GPF_BUILD.txt
