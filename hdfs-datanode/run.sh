#!/bin/bash

if [ -z "$HDFS_NAMENODE_URL" ]; then
  echo "hdfs namenode url not specified"
  echo "Use HDFS_NAMENODE_URL or CORE_CONF_fs_defaultFS to specify hdfs namenode url"
  exit 2
fi

datadir=${HDFS_CONF_dfs_datanode_data_dir#"file://"}
if [ ! -d $datadir ]; then
  echo "Datanode data directory not found: $datedir"
  exit 2
fi

$HADOOP_PREFIX/bin/hdfs --config $HADOOP_CONF_DIR datanode
