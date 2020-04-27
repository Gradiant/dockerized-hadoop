These are docker images of [Apache Hadoop](https://hadoop.apache.org/) HDFS service.

## Hadoop HDFS services

The base image provides a custom entrypoint gets an argument for the type of hdfs server to run:
- namenode
- datanode

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
 
The image provides de following default configuration as environment variables:

| Env variable | Default Value  |
|---|---|
| CORE_CONF_fs_defaultFS | hdfs://`hostname -f`:8020 |
| HDFS_CONF_dfs_namenode_name_dir | file:///hadoop/dfs/name |
| HDFS_CONF_dfs_datanode_data_dir |file:///hadoop/dfs/data |
| CLUSTER_NAME | hadoop | 
| MULTIHOMED_NETWORK | 1 |

The environment variable `MULTIHOMED_NETWORK` configures [multihomed networks].

### Optional non-hadoop configuration
Image also accepts configuration through simple environment variable that translates into specific hadoop configuration variables.
- HDFS_NAMENODE_URL in the form of 'hdfs://NAMENODE_HOST:NAMENODE_PORT'

## Example of usage
We provide two docker-compose files to deploy a 3-datanode and a single-datanode hdfs clusters.

```
docker-compose up -d
```
Then, Hdfs UI is available at:
- [http://localhost:50070](http://localhost:50070) for hadoop 2.x
- [http://localhost:9870](http://localhost:9870) for hadoop 3.x

To undeploy:
```
docker-compose -f tests/docker-compose.yml  down
```

## Testing

We have testing scripts for single and multiple datanode deployments, just provide the name of the docker image to test as environment variable `IMAGE_NAME`. for example:

```
cd scripts/tests
IMAGE_NAME=gradiant/hdfs:2.7.7 ./test-hdfs-single-datanode.sh
IMAGE_NAME=gradiant/hdfs:2.7.7 ./test-hdfs-multiple-datanodes.sh

```

They deploy a hdfs cluster, create a folder in hdfs, copy a file from local to the folder, and remove file and folder. Finally they stop and remove the cluster containers.

