#!/bin/bash

set -ex

IMAGE_NAME="${IMAGE_NAME:-gradiant/hdfs:2.7.7}"

IMAGE_TAG="${IMAGE_NAME#*:}"
IMAGE_REPO="${IMAGE_NAME%:*}"

IMAGE_TAG=$IMAGE_TAG IMAGE_REPO=$IMAGE_REPO docker-compose -f ../../docker-compose.yml up -d

retry=0
maxRetries=5
retryInterval=10

until [ ${retry} -ge ${maxRetries} ]
do
	docker run -ti --rm --net dockerized-hadoop_hdfs $IMAGE_REPO:$IMAGE_TAG \
hdfs dfs -test -e hdfs://namenode:8020/ && break
	echo "Hdfs namenode at hdfs://namenode:8020 not ready"
echo "Retrying [${retry}/${maxRetries}] in ${retryInterval}(s) "
	sleep ${retryInterval}
done

docker run -ti --rm --net dockerized-hadoop_hdfs -e HDFS_NAMENODE_URL=hdfs://namenode:8020 $IMAGE_REPO:$IMAGE_TAG \
/bin/bash -c "
set -ex
hdfs dfs -ls /
hdfs dfs -mkdir /test
hdfs dfs -ls /test
hdfs dfs -copyFromLocal /entrypoint.sh /test
hdfs dfs -ls /test/entrypoint.sh
hdfs dfs -rm /test/entrypoint.sh
hdfs dfs -rmdir /test
"
IMAGE_TAG=$IMAGE_TAG IMAGE_REPO=$IMAGE_REPO docker-compose -f ../../docker-compose.yml down -v