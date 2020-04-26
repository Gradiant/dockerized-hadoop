#!/bin/bash
set -x
HADOOP_VERSION="${HADOOP_VERSION:-3.1.3}"

HADOOP_VERSION=$HADOOP_VERSION docker-compose -f docker-compose-single-datanode.yml up -d

retry=0
maxRetries=5
retryInterval=10

until [ ${retry} -ge ${maxRetries} ]
do
	docker run -ti --rm --net tests_hdfs gradiant/hdfs:$HADOOP_VERSION \
  hdfs dfs -test -e hdfs://namenode:8020/ && break
	echo "Hdfs namenode at hdfs://namenode:8020 not ready"
  echo "Retrying [${retry}/${maxRetries}] in ${retryInterval}(s) "
	sleep ${retryInterval}
done

docker run -ti --rm --net tests_hdfs -e HDFS_NAMENODE_URL=hdfs://namenode:8020 gradiant/hdfs:$HADOOP_VERSION \
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
TEST_RESULT=$?

HADOOP_VERSION=$HADOOP_VERSION docker-compose -f docker-compose-single-datanode.yml down -v

exit $TEST_RESULT
