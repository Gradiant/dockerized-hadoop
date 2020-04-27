#!/bin/bash

set -ex

source variables.env

cd tests

IFS=';' read -ra VERSION_LIST <<< "$HADOOP_VERSIONS"
for HADOOP_VERSION in "${VERSION_LIST[@]}"; do
    IMAGE_TAG=$HADOOP_VERSION
    IMAGE_NAME=$IMAGE_REPO:$IMAGE_TAG ./test-hdfs-single-datanode.sh
    IMAGE_NAME=$IMAGE_REPO:$IMAGE_TAG ./test-hdfs-multiple-datanodes.sh
done
