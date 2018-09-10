#!/bin/bash

datadir=${HDFS_CONF_dfs_datanode_data_dir#"file://"}
if [ ! -d $datadir ]; then
  echo "Datanode data directory not found: $datedir"
  exit 2
fi

$HADOOP_PREFIX/bin/hdfs --config $HADOOP_CONF_DIR datanode
