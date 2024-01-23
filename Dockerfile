FROM centos:7

# Use a base image with the required tools
# Update and upgrade existing packages
RUN yum -y update && yum -y upgrade

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


#docker build --platform linux/amd64 -t my-centos-image .
#docker run -it my-centos-image /bin/bash
