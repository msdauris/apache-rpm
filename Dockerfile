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

##my process##
#docker build --platform linux/arm64 -t my-centos-image .
#docker run --privileged -d -v /sys/fs/cgroup:/sys/fs/cgroup:ro my-centos-image
#docker exec -it [container-id] /bin/bash
#test docker systemctl status
#docker cp bash.sh 181ccb6fff6cb037516196e0b938d9c85095755f0704375569c7fd035bd60066:home
#Successfully copied 3.58kB to 181ccb6fff6cb037516196e0b938d9c85095755f0704375569c7fd035bd60066:home
#on remote, navigate to home
#chmod +x bash.sh
#$bash /home/bash.sh
#to verify
#sudo systemctl start httpd
#Failed to get D-Bus connection: Operation not permittedç

##new process##
#docker build --platform linux/amd64 -t my-centos-image .
#docker run -it my-centos-image
#uname -m
#./bash.sh

##verify rpm package##
