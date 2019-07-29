These are docker images of [Apache Hadoop](https://hadoop.apache.org/).

## Properties

The images have a small footprint ( base docker image is openjdk:8-jre-alpine).

Available hadoop services are:
- HDFS namenode
- HDFS datanode


## Common Hadoop Configuration

The base image provides a custom entrypoint that uses environment variables to set hadoop configuration file properties.

Environment variables must be in the form `<PREFIX>_<HADOOP_PROPERTY>`.

With `PREFIX` one of the following:

```
- CORE_CONF: /etc/hadoop/core-site.xml
- HDFS_CONF: /etc/hadoop/hdfs-site.xml
- YARN_CONF: /etc/hadoop/yarn-site.xml
- HTTPFS_CONF: /etc/hadoop/httpfs-site.xml
- KMS_CONF: /etc/hadoop/KMS-site.xml
```

And the `HADOOP_PROPERTY` should be provided with the following replacements: 

```
. => _
_ => __
- => ___
```

For example: 

_fs.defaultFS_ property of _core-site.xml_ file should be provided as the environment variable:
 
 ``` CORE_CONF_fs_defaultFS```

_dfs.replication_ of _hdfs-site.xml_ file should be provided as:

``` HDFS_CONF_dfs_replication```
 
#### Network

To enable [multihomed networks](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/HdfsMultihoming.html), set the environment variable `MULTIHOMED_NETWORK`.

## HDFS Configuration

hdfs-namenode container accepts `CLUSTER_NAME` environment variable which defaults to "hadoop". 

## Optional non-hadoop configuration
Image also accepts configuration through simple environment variable that translates into specific hadoop configuration variables.
- HDFS_NAMENODE_URL in the form of 'hdfs://NAMENODE_HOST:NAMENODE_PORT'

### Example of usage

Example of a hdfs sinlge namenode and three datanodes.


```
docker run -d --name hdfs-namenode -p 50070:50070 gradiant/hdfs-namenode
docker run -d --link hdfs-namenode --name hdfs-datanode1 -e CORE_CONF_fs_defaultFS=hdfs://hdfs-namenode:8020 gradiant/hdfs-datanode
docker run -d --link hdfs-namenode --name hdfs-datanode2 -e CORE_CONF_fs_defaultFS=hdfs://hdfs-namenode:8020 gradiant/hdfs-datanode
docker run -d --link hdfs-namenode --name hdfs-datanode3 -e CORE_CONF_fs_defaultFS=hdfs://hdfs-namenode:8020 gradiant/hdfs-datanode
```

Testing: native library support:

```
docker exec -ti hdfs-namenode hadoop checknative -a
```

Testing: creating and listing and example folder in hdfs
```
docker exec -ti hdfs-namenode hdfs dfs -mkdir /example
docker exec -ti hdfs-namenode hdfs dfs -ls /
```
