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

##my process##
#docker build --platform linux/amd64 -t my-centos-image .
#docker run --privileged -ti my-centos-image /bin/bash
#WARNING: The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested
#on local
#docker cp bash.sh 181ccb6fff6cb037516196e0b938d9c85095755f0704375569c7fd035bd60066:home
#Successfully copied 3.58kB to 181ccb6fff6cb037516196e0b938d9c85095755f0704375569c7fd035bd60066:home
#on remote, navigate to home
#chmod +x bash.sh
#$bash /home/bash.sh
#warning: remember to run 'libtool --finish /usr/local/apache2/modules'
#to verify
#sudo systemctl start httpd
#Failed to get D-Bus connection: Operation not permitted
