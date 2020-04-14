#!/bin/bash

# Set some sensible defaults
export CORE_CONF_fs_defaultFS=${CORE_CONF_fs_defaultFS:-${HDFS_NAMENODE_URL:-hdfs://`hostname -f`:8020}}

function addProperty() {
  local path=$1
  local name=$2
  local value=$3

  local entry="<property><name>$name</name><value>${value}</value></property>"
  local escapedEntry=$(echo $entry | sed 's/\//\\\//g')
  sed -i "/<\/configuration>/ s/.*/${escapedEntry}\n&/" $path
}

function configure() {
    local path=$1
    local module=$2
    local envPrefix=$3

    local var
    local value
    
    echo "Configuring $module"
    for c in `printenv | perl -sne 'print "$1 " if m/^${envPrefix}_(.+?)=.*/' -- -envPrefix=$envPrefix`; do 
        name=`echo ${c} | perl -pe 's/___/-/g; s/__/@/g; s/_/./g; s/@/_/g;'`
        var="${envPrefix}_${c}"
        value=${!var}
        echo " - Setting $name=$value"
        addProperty $HADOOP_CONF_DIR/$module-site.xml $name "$value"
    done
}

configure $HADOOP_CONF_DIR/core-site.xml core CORE_CONF
configure $HADOOP_CONF_DIR/hdfs-site.xml hdfs HDFS_CONF
configure $HADOOP_CONF_DIR/yarn-site.xml yarn YARN_CONF
configure $HADOOP_CONF_DIR/httpfs-site.xml httpfs HTTPFS_CONF
configure $HADOOP_CONF_DIR/kms-site.xml kms KMS_CONF

if [ "$MULTIHOMED_NETWORK" = "1" ]; then
    echo "Configuring for multihomed network"

    # HDFS
    addProperty $HADOOP_CONF_DIR/hdfs-site.xml dfs.namenode.rpc-bind-host 0.0.0.0
    addProperty $HADOOP_CONF_DIR/hdfs-site.xml dfs.namenode.servicerpc-bind-host 0.0.0.0
    addProperty $HADOOP_CONF_DIR/hdfs-site.xml dfs.namenode.http-bind-host 0.0.0.0
    addProperty $HADOOP_CONF_DIR/hdfs-site.xml dfs.namenode.https-bind-host 0.0.0.0
    addProperty $HADOOP_CONF_DIR/hdfs-site.xml dfs.client.use.datanode.hostname true
    addProperty $HADOOP_CONF_DIR/hdfs-site.xml dfs.datanode.use.datanode.hostname true

    # YARN
    addProperty $HADOOP_CONF_DIR/yarn-site.xml yarn.resourcemanager.bind-host 0.0.0.0
    addProperty $HADOOP_CONF_DIR/yarn-site.xml yarn.nodemanager.bind-host 0.0.0.0
    addProperty $HADOOP_CONF_DIR/yarn-site.xml yarn.nodemanager.bind-host 0.0.0.0
    addProperty $HADOOP_CONF_DIR/yarn-site.xml yarn.timeline-service.bind-host 0.0.0.0

    # MAPRED
    addProperty $HADOOP_CONF_DIR/mapred-site.xml yarn.nodemanager.bind-host 0.0.0.0
fi

node_type=$1

case "$node_type" in
    (namenode)
        shift
        namedir=${HDFS_CONF_dfs_namenode_name_dir#"file://"}
        if [ ! -d $namedir ]; then
          echo "Creating not existing namenode directory: $namedir"
          mkdir -p $namedir
        fi
        if [ "`ls -A $namedir`" == "" ]; then
          echo "Formatting namenode name directory: $namedir"
          $HADOOP_HOME/bin/hdfs --config $HADOOP_CONF_DIR namenode -format $CLUSTER_NAME
        fi
        $HADOOP_HOME/bin/hdfs --config $HADOOP_CONF_DIR namenode $@
      ;;

    (datanode)
      shift
        datadir=${HDFS_CONF_dfs_datanode_data_dir#"file://"}
        if [ ! -d $datadir ]; then
            echo "Creating not existing datanode directory: $datadir"
            mkdir -p $datadir
        fi
        $HADOOP_HOME/bin/hdfs --config $HADOOP_CONF_DIR datanode $@
      ;;
    (*)
      exec "$@"
      ;;
esac