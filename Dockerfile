# Start from CentOS base image
FROM centos:7

# Maintainer information
MAINTAINER "Emma Dauris" <emma.dauris@netcentric.biz>

# Set environment variable
ENV container docker

# Update and upgrade existing packages
RUN yum -y update && yum -y upgrade; yum clean all

# Install systemd
RUN yum -y install systemd; yum clean all; \
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

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

# Define mountable directory
VOLUME [ "/sys/fs/cgroup" ]

# Default command
CMD ["/usr/sbin/init"]


#docker build --platform linux/arm64 -t my-centos-image .
#docker run --privileged -ti -e container=docker -v /sys/fs/cgroup:/sys/fs/cgroup my-centos-image /bin/bash
#docker run --privileged -ti -e container=docker -v /sys/fs/cgroup:/sys/fs/cgroup my-centos-image /usr/sbin/init