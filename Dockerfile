# Start from CentOS base image
FROM centos:7

# Set environment variable
ENV container docker

# Systemd preparation
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;

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

# Volume for systemd
VOLUME [ "/sys/fs/cgroup" ]

# Set init system
CMD ["/usr/sbin/init"]

COPY bash.sh /bash.sh
RUN chmod +x /bash.sh


#docker build --platform linux/arm64 -t my-centos-image .
#docker run --privileged -ti my-centos-image /bin/bash
#docker run --privileged -d -v /sys/fs/cgroup:/sys/fs/cgroup:ro my-centos-image
#docker exec -it 751fdb9a340b /bash.sh
#docker exec -it 751fdb9a340b /bin/bash
#ls /
