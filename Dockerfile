# Start from CentOS base image
FROM centos:7

# Set environment variable
ENV container docker

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

COPY bash.sh /bash.sh
RUN chmod +x /bash.sh
RUN /bash.sh

##new process##
#docker build --platform linux/amd64 -t my-centos-image .
#docker run -it my-centos-image
#uname -m
#./bash.sh

##verify rpm package##
