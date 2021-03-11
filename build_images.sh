#!/bin/bash

set -e

if [ -z $WORKSPACE ];
then
    export WORKSPACE=`pwd`
fi

echo "BUILD_NUMBER: ${BUILD_NUMBER}"

if [ -z $GPF_BUILD ];
then

    if [ -z $BUILD_NUMBER ]; then
        if [ -f "GPF_BUILD.txt" ];
        then
            export GPF_BUILD=$(cat GPF_BUILD.txt)
        fi
        if [ -z $GPF_BUILD ]; then
            export GPF_BUILD=0
        fi

        ((GPF_BUILD+=1))
        echo $GPF_BUILD > GPF_BUILD.txt
    else
        export GPF_BUILD=${BUILD_NUMBER}
    fi

else

    echo "external GPF_BUILD: ${GPF_BUILD}"
fi


if [ -z $BRANCH ];
then
    # export BRANCH="master"
    export BRANCH="release-3.3"
    # export BRANCH="release-3.2.0"
fi

if [ -z ${PUBLISH} ];
then
    echo "Using local docker repository: registry.seqpipe.org:5000"
    export REGISTRY="registry.seqpipe.org:5000"
else
    export REGISTRY="seqpipe"
fi


# prepare sources
${WORKSPACE}/prepare_sources.sh ${BRANCH}

cd ${WORKSPACE}

export GPF_VERSION=$(cat seqpipe-gpf/gpf/VERSION)

export GPF_SERIES=$(cut -d "." -f 1-2 seqpipe-gpf/gpf/VERSION)


echo "GPF_VERSION : ${GPF_VERSION}"
echo "GPF_SERIES  : ${GPF_SERIES}"
echo "GPF_BUILD   : ${GPF_BUILD}"

export TAG="${GPF_VERSION}.${GPF_BUILD}"

echo "TAG         : $TAG"
echo "BRANCH      : $BRANCH"



docker build seqpipe-builder/ -t "${REGISTRY}/seqpipe-builder:${TAG}"
# docker push "${REGISTRY}/seqpipe-builder:${TAG}"

docker build seqpipe-builder/ -t "${REGISTRY}/seqpipe-builder:latest"
# docker push "${REGISTRY}/seqpipe-builder:latest"

cd seqpipe-http
./build_http.sh ${TAG} ${BRANCH} ${REGISTRY}
cd -

cd seqpipe-gpf
./build_gpf.sh ${TAG} ${BRANCH} ${REGISTRY}
cd -


rm -f seqpipe-gpfjs/gpfjs-dist-*.tar.gz
rm -f seqpipe-gpf-full/gpfjs-dist-*.tar.gz

cd seqpipe-gpfjs
./build_gpfjs.sh ${TAG} ${BRANCH} ${REGISTRY}
cd -
cp seqpipe-gpfjs/gpfjs-dist-default-${TAG}.tar.gz seqpipe-gpf-full

cd seqpipe-gpf-full
./build_gpf_full.sh ${TAG} ${BRANCH} ${REGISTRY}
cd -

# for repo in seqpipe-builder seqpipe-gpfjs seqpipe-gpf seqpipe-gpf-full seqpipe-http; do
#     echo "pushing docker image: ${repo}:${TAG}"
#     docker push seqpipe/${repo}:${TAG}
#     docker push seqpipe/${repo}:latest
# done


# cd seqpipe-gpfjs/gpfjs
# git tag -f ${TAG}
# git push origin --tags
# cd -

# cd seqpipe-gpf/gpf
# git tag -f ${TAG}
# git push origin --tags
# cd -

# git tag -f ${TAG}
# echo $GPF_BUILD > GPF_BUILD.txt

# git add GPF_BUILD.txt
# git commit -m "new build done"
# git push origin --tags

# echo $GPF_BUILD > GPF_BUILD.txt
