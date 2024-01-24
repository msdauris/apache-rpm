# Start from CentOS base image
FROM centos:7

# Update and upgrade existing packages
RUN yum -y update && yum -y upgrade; yum clean all

# Install necessary build tools and dependencies
RUN yum -y install \
    wget \
    gcc \
    make \
    rpm-build \
    autoconf \
    libtool \
    doxygen \
    apr-util-devel \
    openssl-devel \
    libuuid-devel \
    lua-devel \
    libxml2-devel

#docker build --platform linux/arm64 -t my-centos-image .
#docker run --privileged -ti my-centos-image /bin/bash