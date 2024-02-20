#!/bin/bash

# Specify the versions
HTTPD_VERSION="2.4.58"
APR_VERSION="1.7.4"
APR_UTIL_VERSION="1.6.3"

# Install necessary development tools and dependencies
yum groupinstall -y "Development Tools"
yum install -y wget rpm-build libuuid-devel

# Create the rpmbuild directories
mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

yum install -y autoconf libtool doxygen

# Download the APR source tarballs
wget -P ~/rpmbuild/SOURCES "https://downloads.apache.org/apr/apr-$APR_VERSION.tar.bz2"
wget -P ~/rpmbuild/SOURCES "https://downloads.apache.org/apr/apr-util-$APR_UTIL_VERSION.tar.bz2"

rpmbuild -tb --clean apr-1.7.4.tar.bz2

cd ~/rpmbuild/RPMS/x86_64
rpm -Uvh apr-1.7.4-1.x86_64.rpm apr-devel-1.7.4-1.x86_64.rpm
yum install apr-util-devel

yum install -y openssl-devel

# Download and rebuild distcache (optional, adjust the version as necessary)
wget "https://archive.fedoraproject.org/pub/archive/fedora/linux/releases/18/Everything/source/SRPMS/d/distcache-1.4.5-23.src.rpm" -P ~/rpmbuild/SOURCES
rpmbuild --rebuild --clean ~/rpmbuild/SOURCES/distcache-1.4.5-23.src.rpm

# Install the built distcache and distcache-devel packages (optional)
cd ~/rpmbuild/RPMS/x86_64
rpm -Uvh distcache-1.4.5-23.x86_64.rpm distcache-devel-1.4.5-23.x86_64.rpm

#mailcap
yum install mailcap

#apache
yum install lua-devel libxml2-devel
wget -P ~/rpmbuild/SOURCES "https://downloads.apache.org/httpd/httpd-$HTTPD_VERSION.tar.bz2"
rpmbuild -tb --clean httpd-2.4.58.tar.bz2
cd ~/rpmbuild/RPMS/x86_64
rpm -Uvh httpd-2.4.58-1.x86_64.rpm
rpm -Uvh httpd-devel-2.4.58-1.x86_64.rpm

# Create a spec file for httpd
cat <<EOT > ~/rpmbuild/SPECS/httpd.spec
Name:           httpd
Version:        $HTTPD_VERSION
Release:        1%{?dist}
Summary:        Apache HTTP Server

License:        ASL 2.0
URL:            https://httpd.apache.org/
Source0:        https://downloads.apache.org/httpd/httpd-$HTTPD_VERSION.tar.bz2
Source1:        https://downloads.apache.org/apr/apr-$APR_VERSION.tar.bz2
Source2:        https://downloads.apache.org/apr/apr-util-$APR_UTIL_VERSION.tar.bz2

BuildRequires:  gcc, make, pcre-devel, expat-devel, libxml2-devel, openssl-devel, openldap-devel, lua-devel, apr-devel, apr-util-devel

%description
Apache HTTP Server, a robust, commercial-grade, featureful, and freely-available source code implementation of an HTTP (Web) server.

%prep
%setup -q -n httpd-%{version}
tar xzf %{SOURCE1} -C srclib/
tar xzf %{SOURCE2} -C srclib/
mv srclib/apr-$APR_VERSION srclib/apr
mv srclib/apr-util-$APR_UTIL_VERSION srclib/apr-util

%build
./configure --prefix=/usr/local/apache2 \
            --enable-ssl \
            --enable-so \
            --enable-authnz-ldap \
            --enable-lua \
            --enable-proxy-html
make %{?_smp_mflags}

%install
make install DESTDIR=%{buildroot}

%files
/usr/local/apache2

%changelog
* Mon Feb 19 2024 Emma Dauris <emma.dauris@netcentric.biz> - %{version}-1
- First build
EOT

# Build the RPM
rpmbuild -ba ~/rpmbuild/SPECS/httpd.spec

echo "RPM Build Complete. Check ~/rpmbuild/RPMS/ for the RPM file."
