ARG VERSION=2.7.7
FROM gradiant/hadoop-base:$VERSION

LABEL maintainer="cgiraldo@gradiant.org"
LABEL organization="gradiant.org"

COPY run.sh /run.sh

ENV CLUSTER_NAME hadoop
ENV HDFS_CONF_dfs_namenode_name_dir=file:///hadoop/dfs/name
RUN adduser -D -S -u 1000 -G root hdfs && \
    mkdir -p /hadoop/dfs/name && \
    chown -R hdfs:root /hadoop && \
    chown -R hdfs:root $HADOOP_CONF_DIR

USER hdfs

VOLUME /hadoop

CMD ["/run.sh"]
