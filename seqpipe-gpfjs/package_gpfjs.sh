#!/bin/bash

set -e

if [ "$1" ]; then
    export TAG=$1
    echo "TAG=${TAG}"
else
    echo 'ERROR: requires a non-empty version TAG'
    exit 1
fi

cd /work/gpfjs

rm -rf node_modules package-lock.json
npm install

rm -rf dist 
ng build --prod --aot --configuration 'hg19' --base-href '/hg19/' --deploy-url '/hg19/'

python ppindex.py

cd /work/gpfjs/dist/gpfjs && \
    tar zcvf /work/gpfjs-dist-hg19-${TAG}.tar.gz . && \
    cd /work/gpfjs # && \
    # ln -sf gpfjs-dist-hg19-${TAG}.tar.gz gpfjs-dist-hg19-latest.tar.gz

rm -rf dist 
ng build --prod --aot --configuration 'hg38' --base-href '/hg38/' --deploy-url '/hg38/'

python ppindex.py

cd /work/gpfjs/dist/gpfjs && \
    tar zcvf /work/gpfjs-dist-hg38-${TAG}.tar.gz . && \
    cd /work/gpfjs # && \
    # ln -sf gpfjs-dist-hg38-${TAG}.tar.gz gpfjs-dist-hg38-latest.tar.gz


rm -rf dist 
ng build --prod --aot --configuration 'hg_test' --base-href '/hg_test/' --deploy-url '/hg_test/'

python ppindex.py

cd /work/gpfjs/dist/gpfjs && \
    tar zcvf /work/gpfjs-dist-hg_test-${TAG}.tar.gz . &&\
    cd /work/gpfjs # && \
    # ln -sf gpfjs-dist-hg_test-${TAG}.tar.gz gpfjs-dist-hg_test-latest.tar.gz




