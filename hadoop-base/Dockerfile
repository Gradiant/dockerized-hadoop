FROM openjdk:8u171-jdk-alpine3.8 as builder

LABEL maintainer="cgiraldo@gradiant.org"
LABEL organization="gradiant.org"

ARG VERSION=2.7.7
ENV HADOOP_VERSION=$VERSION

RUN apk add --no-cache bash build-base maven autoconf automake libtool cmake zlib-dev libressl-dev fts-dev  libtirpc-dev && mkdir /opt
# Building Protobuf 2.5.0
RUN cd /opt && wget https://github.com/google/protobuf/releases/download/v2.5.0/protobuf-2.5.0.tar.gz && \
  tar xvf protobuf-2.5.0.tar.gz && cd protobuf-2.5.0 && ./autogen.sh && ./configure --prefix=/usr && \
  make && make install

# building hadoop

RUN wget -qO- http://apache.rediris.es/hadoop/common/hadoop-2.7.7/hadoop-2.7.7-src.tar.gz | tar xvz -C /opt
RUN ln -s /opt/hadoop-2.7.7-src /opt/hadoop-src && cd /opt/hadoop-src && \
    ## - error: 'sys_nerr' undeclared (first use in this function)
    sed -ri 's/^#if defined\(__sun\)/#if 1/g' hadoop-common-project/hadoop-common/src/main/native/src/exception.c \
    ## - bad substitution at line 11
    && sed -ri 's/executable="sh"/executable="bash"/g' hadoop-project-dist/pom.xml \
    ## - error: 'sys_nerr' undeclared (first use in this function)
    && sed -ri 's/^#if defined\(__sun\)/#if 1/g' hadoop-common-project/hadoop-common/src/main/native/src/exception.c \
    ## - error: undefined reference to fts_*
    && sed -ri 's/^( *container)/\1\n    fts/g' hadoop-yarn-project/hadoop-yarn/hadoop-yarn-server/hadoop-yarn-server-nodemanager/src/CMakeLists.txt \
    ## - warning: implicit declaration of function 'setnetgrent'
    && sed -ri 's/^(.*JniBasedUnixGroupsNetgroupMapping.c)/#\1/g' hadoop-common-project/hadoop-common/src/CMakeLists.txt \
    ## - fatal error: rpc/types.h: No such file or directory
    && sed -ri 's#^(include_directories.*)#\1\n    /usr/include/tirpc#' hadoop-tools/hadoop-pipes/src/CMakeLists.txt \
    && sed -ri 's/^( *pthread)/\1\n    tirpc/g' hadoop-tools/hadoop-pipes/src/CMakeLists.txt
RUN cd /opt/hadoop-src && mvn package -Pdist,native -DskipTests -DskipDocs -Dtar
RUN mkdir -p /opt/hadoop/usr/lib
RUN cp -r /opt/hadoop-src/hadoop-dist/target/hadoop-2.7.7/* /opt/hadoop/
RUN cp -r /opt/hadoop-src/hadoop-common-project/hadoop-common/target/native/target/usr/local/lib/* /opt/hadoop/lib/native/
RUN cp -r /opt/hadoop-src/hadoop-hdfs-project/hadoop-hdfs/target/native/target/usr/local/lib/* /opt/hadoop/lib/native/


FROM openjdk:8u171-jre-alpine3.8 as hadoop-base

LABEL maintainer="cgiraldo@gradiant.org"
LABEL organization="gradiant.org"
ARG VERSION=2.7.7
ENV HADOOP_VERSION=$VERSION

COPY --from=builder /opt/hadoop/ /opt/hadoop/

ENV HADOOP_PREFIX=/opt/hadoop
ENV HADOOP_CONF_DIR=$HADOOP_PREFIX/etc/hadoop
ENV PATH=$PATH:$HADOOP_PREFIX/bin
RUN apk add --no-cache \
        bash \
        perl \
        bzip2 \
        fts \
        fuse \
        libressl-dev \
        libtirpc \
        snappy \
        zlib && \
    cp $HADOOP_CONF_DIR/mapred-site.xml.template $HADOOP_CONF_DIR/mapred-site.xml && \
    mkdir -p /logs

ENV MULTIHOMED_NETWORK=1


COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
