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
ng build --prod --aot --configuration 'default' --base-href '/gpf_prefix/' --deploy-url '/gpf_prefix/'

python ppindex.py

cd /work/gpfjs/dist/gpfjs && \
    tar zcvf /work/gpfjs-dist-default-${TAG}.tar.gz . &&\
    cd /work/gpfjs 
