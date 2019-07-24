#!/bin/bash

VERSION=3.1.2

docker build --build-arg VERSION=$VERSION  --target hadoop-base -t gradiant/hadoop-base:$VERSION hadoop-base
docker build --build-arg VERSION=$VERSION -t gradiant/hdfs-namenode:$VERSION hdfs-namenode
docker build --build-arg VERSION=$VERSION -t gradiant/hdfs-datanode:$VERSION hdfs-datanode

docker tag gradiant/hadoop-base:$VERSION gradiant/hadoop-base:latest
docker tag gradiant/hdfs-namenode:$VERSION gradiant/hdfs-namenode:latest
docker tag gradiant/hdfs-datanode:$VERSION gradiant/hdfs-datanode:latest
