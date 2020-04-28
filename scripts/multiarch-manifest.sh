#!/bin/bash

set -ex

source variables.env

IFS=',' read -ra ARCH_LIST <<< "$BUILD_ARCHS"
IFS=';' read -ra VERSION_LIST <<< "$HADOOP_VERSIONS"

 # Use docker cli v18.09.6 to use experimental manifest feature
curl -SL "https://download.docker.com/linux/static/stable/x86_64/docker-18.09.6.tgz" | tar xzv docker/docker --transform='s/.*/docker-cli/'
mkdir -p dockerconfig
# Add auths and experimental to docker-cli config
echo '{"experimental":"enabled"}' > dockerconfig/config.json
./docker-cli --config="./dockerconfig" login

for HADOOP_VERSION in "${VERSION_LIST[@]}"; do
    IMAGE_TAG=$HADOOP_VERSION
    VIRTUAL_IMAGE=$IMAGE_REPO:$IMAGE_TAG   
    manifest_list="$VIRTUAL_IMAGE-amd64 $VIRTUAL_IMAGE-${BUILD_ARCHS//,/ $VIRTUAL_IMAGE-}"
    eval ./docker-cli --config="./dockerconfig" manifest create $VIRTUAL_IMAGE $manifest_list
    for BUILD_ARCH in "${ARCH_LIST[@]}"; do
      if [ "$BUILD_ARCH" == "arm32v7" ]; then
      ./docker-cli --config="./dockerconfig" manifest annotate $VIRTUAL_IMAGE $VIRTUAL_IMAGE-$BUILD_ARCH --os linux --arch arm --variant v7
      elif [ "$BUILD_ARCH" == "arm64v8" ]; then
      ./docker-cli --config="./dockerconfig" manifest annotate $VIRTUAL_IMAGE $VIRTUAL_IMAGE-$BUILD_ARCH --os linux --arch arm64 --variant v8
      fi
    done
    ./docker-cli --config="./dockerconfig" manifest push $VIRTUAL_IMAGE
    if [ "$IMAGE_TAG" == "$LATEST_TAG" ]; then
      eval ./docker-cli --config="./dockerconfig" manifest create $IMAGE_REPO:latest $manifest_list
      for BUILD_ARCH in "${ARCH_LIST[@]}"; do
        if [ "$BUILD_ARCH" == "arm32v7" ]; then
          ./docker-cli --config="./dockerconfig" manifest annotate $IMAGE_REPO:latest $VIRTUAL_IMAGE-$BUILD_ARCH --os linux --arch arm --variant v7
        elif [ "$BUILD_ARCH" == "arm64v8" ]; then
          ./docker-cli --config="./dockerconfig" manifest annotate $IMAGE_REPO:latest $VIRTUAL_IMAGE-$BUILD_ARCH --os linux --arch arm64 --variant v8
        fi
      done
      ./docker-cli --config="./dockerconfig" manifest push $IMAGE_REPO:latest
    fi
done
rm -r docker-cli dockerconfig

