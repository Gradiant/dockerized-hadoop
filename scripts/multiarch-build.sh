#!/bin/bash

set -ex

source variables.env

set_QEMU_ARCH() {
  case $1 in
    amd64   ) QEMU_ARCH="x86_64" ;;
    arm32v7 ) QEMU_ARCH="arm" ;;
    arm64v8 ) QEMU_ARCH="aarch64" ;;
    i386    ) QEMU_ARCH="i386"  ;;
    ppc64le ) QEMU_ARCH="ppc64le" ;;
    s390x   ) QEMU_ARCH="s390x"  ;;
  esac
}


IFS=',' read -ra ARCH_LIST <<< "$BUILD_ARCHS"
IFS=';' read -ra VERSION_LIST <<< "$HADOOP_VERSIONS"

docker run --rm --privileged multiarch/qemu-user-static:register --reset

for BUILD_ARCH in "${ARCH_LIST[@]}"; do
  for HADOOP_VERSION in "${VERSION_LIST[@]}"; do
    IMAGE_TAG=$HADOOP_VERSION
    set_QEMU_ARCH $BUILD_ARCH
    QEMU_USER_STATIC_DOWNLOAD_URL="https://github.com/multiarch/qemu-user-static/releases/download"
    QEMU_USER_STATIC_LATEST_TAG=$(curl -s https://api.github.com/repos/multiarch/qemu-user-static/tags \
    | grep 'name.*v[0-9]' \
    | head -n 1 \
    | cut -d '"' -f 4)
    QEMU_USER_STATIC_URL="${QEMU_USER_STATIC_DOWNLOAD_URL}/${QEMU_USER_STATIC_LATEST_TAG}/x86_64_qemu-${QEMU_ARCH}-static.tar.gz"
    curl -SL "${QEMU_USER_STATIC_URL}" \
    | tar xzv
    chmod +x qemu-$QEMU_ARCH-static
    mv qemu-$QEMU_ARCH-static ..

    docker build -t $IMAGE_REPO:$IMAGE_TAG-$BUILD_ARCH \
      --build-arg arch=$BUILD_ARCH \
      --build-arg qemu_static=qemu-$QEMU_ARCH-static \
      -f ../Dockerfile.multiarch ..
    rm ../qemu-$QEMU_ARCH-static
  done
done






