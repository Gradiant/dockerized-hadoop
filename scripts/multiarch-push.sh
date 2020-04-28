#!/bin/bash

set -ex

source variables.env

IFS=',' read -ra ARCH_LIST <<< "$BUILD_ARCHS"
IFS=';' read -ra VERSION_LIST <<< "$HADOOP_VERSIONS"


for HADOOP_VERSION in "${VERSION_LIST[@]}"; do
  IMAGE_TAG=$HADOOP_VERSION
  VIRTUAL_IMAGE=$IMAGE_REPO:$IMAGE_TAG
  echo "Moving image to amd64"
  docker tag $VIRTUAL_IMAGE $VIRTUAL_IMAGE-amd64
  docker push $VIRTUAL_IMAGE-amd64
  for BUILD_ARCH in "${ARCH_LIST[@]}"; do
    echo " pushing image $VIRTUAL_IMAGE-$BUILD_ARCH to registry"
    docker push $VIRTUAL_IMAGE-$BUILD_ARCH
  done
done

