#!/bin/bash


docker build . -t seqpipe/seqpipe-http:${TAG} --build-arg VERSION_TAG=${TAG}
docker build . -t seqpipe/seqpipe-http:latest --build-arg VERSION_TAG=${TAG}
