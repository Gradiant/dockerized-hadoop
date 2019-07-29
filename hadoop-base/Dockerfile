FROM openjdk:8-jdk-alpine as builder

LABEL maintainer="cgiraldo@gradiant.org"
LABEL organization="gradiant.org"


RUN apk add --no-cache bash build-base maven autoconf automake libtool cmake zlib-dev openssl-dev fts-dev  libtirpc-dev && mkdir -p /opt
# Building Protobuf 2.5.0
RUN cd /opt && wget https://github.com/google/protobuf/releases/download/v2.5.0/protobuf-2.5.0.tar.gz && \
  tar xvf protobuf-2.5.0.tar.gz && cd protobuf-2.5.0 && ./autogen.sh && ./configure --prefix=/usr && \
  make && make install

# Building intel Intelligent Storage Acceleration Library
RUN apk add --no-cache yasm
RUN wget -qO- https://github.com/intel/isa-l/archive/v2.27.0.tar.gz | tar xvz -C /opt
RUN cd /opt/isa-l-2.27.0 && \
    make -f Makefile.unx && \
    cp bin/libisal.so bin/libisal.so.2 /lib/

# building hadoop
ARG version=3.1.2
ENV HADOOP_VERSION=$version

RUN apk add tar --no-cache libexecinfo-dev bzip2-dev snappy-dev zstd-dev openssl-dev git

RUN wget -qO- http://apache.rediris.es/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION-src.tar.gz | tar xvz -C /opt
RUN ln -s /opt/hadoop-$HADOOP_VERSION-src /opt/hadoop-src && cd /opt/hadoop-src && \
    ## - error: 'sys_nerr' undeclared (first use in this function)
    sed -ri 's/^#if defined\(__sun\)/#if 1/g' hadoop-common-project/hadoop-common/src/main/native/src/exception.c && \
    ## - warning: implicit declaration of function 'setnetgrent'
    sed -ri 's/^(.*JniBasedUnixGroupsNetgroupMapping.c)/#\1/g' hadoop-common-project/hadoop-common/src/CMakeLists.txt
RUN cd /opt/hadoop-src && mvn package -f hadoop-common-project -Pdist,native -DskipTests -DskipDocs -Dtar
RUN cd /opt/hadoop-src && mvn package -f hadoop-hdfs-project -Pdist,native -DskipTests -DskipDocs -Dtar
#mapreduce native profile produce an error in Apache Hadoop MapReduce NativeTask due to alpine linux and backtrace libexecinfo support so we disable it
RUN cd /opt/hadoop-src && mvn package -f hadoop-mapreduce-project -Pdist -DskipTests -DskipDocs -Dtar
RUN cd /opt/hadoop-src && mvn package -f hadoop-yarn-project -Pdist,native -DskipTests -DskipDocs -Dtar

RUN cd /opt/hadoop-src && mvn package -f hadoop-client-modules -Pdist,native -DskipTests -DskipDocs -Dtar

RUN cd /opt/hadoop-src && mvn --projects hadoop-dist package -DskipTests -DskipDocs -Dtar
RUN mv /opt/hadoop-src/hadoop-dist/target/hadoop-${HADOOP_VERSION} /opt/
RUN ln -s /opt/hadoop-${HADOOP_VERSION} /opt/hadoop


FROM openjdk:8-jre-alpine as hadoop-base

LABEL maintainer="cgiraldo@gradiant.org" \
      organization="gradiant.org"

ARG VERSION=3.1.2
ENV HADOOP_VERSION=$VERSION \
    HADOOP_HOME=/opt/hadoop

ENV HADOOP_PREFIX=$HADOOP_HOME \
    HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop \
    PATH=$PATH:$HADOOP_HOME/bin \
    MULTIHOMED_NETWORK=1

RUN apk add --no-cache \
        bash \
        procps \
        perl \
        bzip2 \
        fts \
        fuse \
        openssl-dev \
        libtirpc \
        snappy \
        zlib \
        zstd-dev \
        curl && \
    mkdir -p /logs

COPY --from=builder /opt/hadoop /opt/hadoop
COPY --from=builder /lib/libisal.* /lib/

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
