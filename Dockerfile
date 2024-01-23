FROM centos:7

# Use a base image with the required tools
# Update and upgrade existing packages
RUN yum -y update && yum -y upgrade

# Install necessary build tools and dependencies
RUN yum -y install \
    wget \
    gcc \
    make \
    #rpm-build \
    autoconf \
    libtool \
    doxygen \
    apr-util-devel \
    openssl-devel \
    libuuid-devel \
    lua-devel \
    libxml2-devel

# Download and build APR
WORKDIR /usr/src
RUN wget https://archive.apache.org/dist/apr/apr-1.7.4.tar.bz2 && \
    tar -xjf apr-1.7.4.tar.bz2 && \
    cd apr-1.7.4 && \
    ./configure && \
    make && \
    make install
    #rpmbuild -tb --clean -v apr-1.7.4.tar.bz2

# Install APR
#WORKDIR /root/rpmbuild/RPMS/x86_64
#RUN rpm -Uvh /usr/src/rpmbuild/RPMS/x86_64/apr-1.7.4-1.x86_64.rpm /usr/src/rpmbuild/RPMS/x86_64/apr-devel-1.7.4-1.x86_64.rpm

# Install additional dependencies
#WORKDIR /usr/src
#RUN wget https://archive.fedoraproject.org/pub/archive/fedora/linux/releases/18/Everything/source/SRPMS/d/distcache-1.4.5-23.src.rpm && \
 #   rpmbuild --rebuild --clean distcache-1.4.5-23.src.rpm

#WORKDIR /root/rpmbuild/RPMS/x86_64
#RUN rpm -Uvh /usr/src/rpmbuild/RPMS/x86_64/distcache-1.4.5-23.x86_64.rpm /usr/src/rpmbuild/RPMS/x86_64/distcache-devel-1.4.5-23.x86_64.rpm

# Download Apache HTTP Server source code
WORKDIR /usr/src
RUN wget http://archive.apache.org/dist/httpd/httpd-2.4.58.tar.bz2 && \
    tar -xjf httpd-2.4.58.tar.bz2

# Build and install Apache HTTP Server
WORKDIR /usr/src/httpd-2.4.58
RUN ./configure && \
    make && \
    make install

# Create RPM package for Apache HTTP Server
#WORKDIR /root/rpmbuild
#RUN mkdir -p {BUILD,RPMS,SOURCES,SPECS,SRPMS}
#COPY apache.spec /root/rpmbuild/SPECS/
#RUN rpmbuild -ba SPECS/apache.spec
