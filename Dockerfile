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
    pcre-devel \
    expat-devel \
    apr-devel \
    rpm-build \
    autoconf \
    libtool \
    doxygen \
    apr-util-devel \
    openssl-devel \
    openldap-devel \
    libuuid-devel \
    lua-devel \
    libxml2-devel

COPY bash.sh /bash.sh
RUN chmod +x /bash.sh
CMD ["/bin/bash", "/bash.sh"] # Run the script when the container starts

##new process##
#docker build --platform linux/amd64 -t my-centos-image .
#docker run -it my-centos-image
#uname -m
#./bash.sh

##verify rpm package##