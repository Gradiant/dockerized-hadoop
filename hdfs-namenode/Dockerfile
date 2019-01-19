ARG VERSION=2.7.7
FROM gradiant/hadoop-base:$VERSION

LABEL maintainer="cgiraldo@gradiant.org"
LABEL organization="gradiant.org"

ENV HDFS_CONF_dfs_namenode_name_dir=file:///hadoop/dfs/name
RUN mkdir -p /hadoop/dfs/name
VOLUME /hadoop

ADD run.sh /run.sh

CMD ["/run.sh"]
