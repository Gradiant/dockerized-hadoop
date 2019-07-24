ARG VERSION=3.1.2
FROM gradiant/hadoop-base:$VERSION

LABEL maintainer="cgiraldo@gradiant.org"
LABEL organization="gradiant.org"

COPY run.sh /run.sh

ENV HDFS_CONF_dfs_datanode_data_dir=file:///hadoop/dfs/data

RUN adduser -D -S -u 1000 -G root hdfs && \
    mkdir -p /hadoop/dfs/data && \
    chown -R hdfs:root /hadoop && \
    chown -R hdfs:root $HADOOP_HOME && \
    chown -R hdfs:root $HADOOP_CONF_DIR

USER hdfs

VOLUME /hadoop


CMD ["/run.sh"]
