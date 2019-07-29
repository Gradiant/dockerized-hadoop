FROM openjdk:8-jdk-alpine as builder

LABEL maintainer="cgiraldo@gradiant.org"
LABEL organization="gradiant.org"

# We enable alpine 3.8 repo to install openssl 1.0 since hadoop 2.7 native libs will not build with openssl 1.1 (alpine 3.9)
# hadoop checknative -a with openssl 1.1 reports openssl false 'EVP_CIPHER_CTX_cleanup'
RUN echo "@3.8 http://dl-cdn.alpinelinux.org/alpine/v3.8/main" >> /etc/apk/repositories
RUN apk add --no-cache bash build-base maven autoconf automake libtool cmake zlib-dev openssl-dev@3.8 fts-dev  libtirpc-dev && mkdir -p /opt
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

ARG version=2.7.7
ENV HADOOP_VERSION=$version

RUN apk add tar --no-cache libexecinfo-dev bzip2-dev snappy-dev zstd-dev openssl-dev@3.8 git

RUN wget -qO- http://apache.rediris.es/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION-src.tar.gz | tar xvz -C /opt
RUN ln -s /opt/hadoop-$HADOOP_VERSION-src /opt/hadoop-src && cd /opt/hadoop-src && \
    ## - error: 'sys_nerr' undeclared (first use in this function)
    sed -ri 's/^#if defined\(__sun\)/#if 1/g' hadoop-common-project/hadoop-common/src/main/native/src/exception.c \
    ## - error: 'sys_nerr' undeclared (first use in this function)
    && sed -ri 's/^#if defined\(__sun\)/#if 1/g' hadoop-common-project/hadoop-common/src/main/native/src/exception.c \
    ## - error: undefined reference to fts_*
    && sed -ri 's/^( *container)/\1\n    fts/g' hadoop-yarn-project/hadoop-yarn/hadoop-yarn-server/hadoop-yarn-server-nodemanager/src/CMakeLists.txt \
    ## - warning: implicit declaration of function 'setnetgrent'
    && sed -ri 's/^(.*JniBasedUnixGroupsNetgroupMapping.c)/#\1/g' hadoop-common-project/hadoop-common/src/CMakeLists.txt \
    ## - fatal error: rpc/types.h: No such file or directory
    && sed -ri 's#^(include_directories.*)#\1\n    /usr/include/tirpc#' hadoop-tools/hadoop-pipes/src/CMakeLists.txt \
    && sed -ri 's/^( *pthread)/\1\n    tirpc/g' hadoop-tools/hadoop-pipes/src/CMakeLists.txt

#solving error compiling against openssl 1.1.0 https://issues.apache.org/jira/browse/HADOOP-14597
COPY HADOOP-14597.04.patch /opt/
RUN cd /opt/hadoop-src/ && patch -p1 < ../HADOOP-14597.04.patch
RUN cd /opt/hadoop-src && mvn package -f hadoop-common-project -Pdist,native -DskipTests -DskipDocs -Dtar
RUN cd /opt/hadoop-src && mvn package -f hadoop-hdfs-project -Pdist,native -DskipTests -DskipDocs -Dtar
RUN cd /opt/hadoop-src && mvn package -f hadoop-mapreduce-project -Pdist,native -DskipTests -DskipDocs -Dtar
RUN cd /opt/hadoop-src && mvn package -f hadoop-yarn-project -Pdist,native -DskipTests -DskipDocs -Dtar
RUN cd /opt/hadoop-src && mvn package -f hadoop-client -Pdist,native -DskipTests -DskipDocs -Dtar
RUN cd /opt/hadoop-src && mvn package -f hadoop-tools -Pdist,native -DskipTests -DskipDocs -Dtar
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

RUN echo "@3.8 http://dl-cdn.alpinelinux.org/alpine/v3.8/main" >> /etc/apk/repositories && \
    apk add --no-cache \
        bash \
        procps \
        perl \
        bzip2 \
        fts \
        fuse \
        openssl-dev@3.8 \
        libtirpc \
        snappy \
        zlib \
        zstd \
        curl && \
    # cp $HADOOP_CONF_DIR/mapred-site.xml.template $HADOOP_CONF_DIR/mapred-site.xml && \
    mkdir -p /logs

COPY --from=builder /opt/hadoop /opt/hadoop

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
