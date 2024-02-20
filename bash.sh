#!/bin/bash

# Specify the versions
HTTPD_VERSION="2.4.58"
APR_VERSION="1.7.4"
APR_UTIL_VERSION="1.6.3"

# Install necessary development tools and dependencies
yum groupinstall -y "Development Tools"
yum install -y wget rpm-build libuuid-devel autoconf libtool doxygen openssl-devel lua-devel libxml2-devel mailcap apr-util-devel

# Create the rpmbuild directories
mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

# Download the APR and HTTPD source tarballs
for file in "apr-$APR_VERSION.tar.bz2" "apr-util-$APR_UTIL_VERSION.tar.bz2" "httpd-$HTTPD_VERSION.tar.bz2"; do
    wget -P ~/rpmbuild/SOURCES "https://downloads.apache.org/apr/$file"
done

# Build APR from source
echo "Building APR..."
rpmbuild -tb --clean ~/rpmbuild/SOURCES/apr-$APR_VERSION.tar.bz2 || { echo "APR build failed"; exit 1; }

# Install APR
cd ~/rpmbuild/RPMS/x86_64
rpm -Uvh apr-$APR_VERSION-1.x86_64.rpm apr-devel-$APR_VERSION-1.x86_64.rpm || { echo "APR installation failed"; exit 1; }

# Download and rebuild distcache (optional)
echo "Downloading and building distcache..."
wget "https://archive.fedoraproject.org/pub/archive/fedora/linux/releases/18/Everything/source/SRPMS/d/distcache-1.4.5-23.src.rpm" -P ~/rpmbuild/SOURCES
rpmbuild --rebuild --clean ~/rpmbuild/SOURCES/distcache-1.4.5-23.src.rpm || { echo "Distcache build failed"; exit 1; }

# Install the built distcache packages (optional)
cd ~/rpmbuild/RPMS/x86_64
rpm -Uvh distcache-1.4.5-23.x86_64.rpm distcache-devel-1.4.5-23.x86_64.rpm || { echo "Distcache installation failed"; exit 1; }

# Build Apache HTTPD from source
echo "Building Apache HTTPD..."
rpmbuild -tb --clean ~/rpmbuild/SOURCES/httpd-$HTTPD_VERSION.tar.bz2 || { echo "HTTPD build failed"; exit 1; }

# Install Apache HTTPD
cd ~/rpmbuild/RPMS/x86_64
rpm -Uvh httpd-$HTTPD_VERSION-1.x86_64.rpm httpd-devel-$HTTPD_VERSION-1.x86_64.rpm || { echo "HTTPD installation failed"; exit 1; }

# Build the RPM
echo "Building RPM package..."
rpmbuild -ba ~/rpmbuild/SPECS/httpd.spec || { echo "RPM package build failed"; exit 1; }

echo "RPM Build Complete. Check ~/rpmbuild/RPMS/ for the RPM file."
