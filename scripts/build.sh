#!/bin/bash

set -ex

source variables.env


IFS=';' read -ra VERSION_LIST <<< "$HADOOP_VERSIONS"

for HADOOP_VERSION in "${VERSION_LIST[@]}"; do
    IMAGE_TAG=$HADOOP_VERSION
    docker build -t $IMAGE_REPO:$IMAGE_TAG --build-arg version=$HADOOP_VERSION ..
done