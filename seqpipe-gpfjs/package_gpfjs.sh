#!/bin/bash

set -e

if [ "$1" ]; then
    export TAG=$1
    echo "TAG=${TAG}"
else
    echo 'ERROR: requires a non-empty version TAG'
    exit 1
fi

chown -R 1000:1000 /work/gpfjs

cd /work/gpfjs

ls -l .


echo "[package_gpfjs] going to remove node_modules..."
rm -rf node_modules package-lock.json

echo "[package_gpfjs] going to run npm install..."
npm install

echo "[package_gpfjs] going to remove dist..."
rm -rf dist 


echo "[package_gpfjs] going to build gpfjs..."
ng build --prod --aot --configuration 'default' --base-href '/gpf_prefix/' --deploy-url '/gpf_prefix/'

echo "[package_gpfjs] going to run ppindex.py..."
python ppindex.py

echo "[package_gpfjs] going to tar the distribution..."
cd /work/gpfjs/dist/gpfjs && \
    tar zcvf /work/gpfjs-dist-default-${TAG}.tar.gz . &&\
    cd /work/gpfjs 
