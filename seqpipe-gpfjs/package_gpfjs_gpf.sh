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
ng build --prod --aot --configuration 'hg19' --base-href '/gpf19/' --deploy-url '/gpf19/'
# npm run build -- --prod --aot --configuration gpf19 --deploy-url=/gpf19/ --base-href=/gpf19/

python ppindex.py

cd /work/gpfjs/dist/gpfjs && \
    tar zcvf /work/gpfjs-dist-gpf19-${TAG}.tar.gz . && \
    cd /work/gpfjs # && \
    # ln -sf gpfjs-dist-gpf19-${TAG}.tar.gz gpfjs-dist-gpf19-latest.tar.gz

rm -rf dist 
ng build --prod --aot --configuration 'hg38' --base-href '/gpf38/' --deploy-url '/gpf38/'
# npm run build -- --prod --aot --configuration gpf19 --deploy-url=/gpf19/ --base-href=/gpf19/

python ppindex.py

cd /work/gpfjs/dist/gpfjs && \
    tar zcvf /work/gpfjs-dist-gpf38-${TAG}.tar.gz . && \
    cd /work/gpfjs # && \
    # ln -sf gpfjs-dist-gpf38-${TAG}.tar.gz gpfjs-dist-gpf38-latest.tar.gz


rm -rf dist 
ng build --prod --aot --configuration 'hg_test' --base-href '/gpf_test/' --deploy-url '/gpf_test/'

python ppindex.py

cd /work/gpfjs/dist/gpfjs && \
    tar zcvf /work/gpfjs-dist-gpf_test-${TAG}.tar.gz . && \
    cd /work/gpfjs # && \
    # ln -sf gpfjs-dist-gpf_test-${TAG}.tar.gz gpfjs-dist-gpf_test-latest.tar.gz




