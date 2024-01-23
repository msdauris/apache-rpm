#!/bin/bash

# Specify the version of httpd you want to download
HTTPD_VERSION="2.4.58"

# Install necessary development tools and dependencies
sudo yum groupinstall -y "Development Tools"
sudo yum install -y rpm-build wget

# Create the rpmbuild directories
mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

# Download the source tarball of the specified version of httpd
wget -P ~/rpmbuild/SOURCES "https://downloads.apache.org/httpd/httpd-$HTTPD_VERSION.tar.gz"

# Download the additional necessary files
wget -P ~/rpmbuild/SOURCES "https://downloads.apache.org/apr/apr-1.7.4.tar.gz"
wget -P ~/rpmbuild/SOURCES "https://downloads.apache.org/apr/apr-util-1.6.3.tar.gz"

# Create a basic spec file for RPM
cat <<EOT > ~/rpmbuild/SPECS/httpd.spec
Name:           httpd
Version:        $HTTPD_VERSION
Release:        1%{?dist}
Summary:        Apache HTTP Server

License:        ASL 2.0
URL:            https://httpd.apache.org/
Source0:        https://downloads.apache.org/httpd/httpd-%{version}.tar.gz
Source1:        https://downloads.apache.org/apr/apr-1.7.4.tar.gz
Source2:        https://downloads.apache.org/apr/apr-util-1.6.3.tar.gz

BuildRequires:  gcc, make, pcre-devel, expat-devel, libxml2-devel

%description
The Apache HTTP Server, a robust, commercial-grade, featureful, and freely-available source code implementation of an HTTP (Web) server.

%prep
%setup -q -n httpd-%{version}
tar xzf %{SOURCE1}
tar xzf %{SOURCE2}
mv apr-1.7.4 srclib/apr
mv apr-util-1.6.3 srclib/apr-util

%build
./configure --prefix=/usr/local/apache2 --with-included-apr
make %{?_smp_mflags}

%install
make install DESTDIR=%{buildroot}

%files
/usr/local/apache2

%changelog
* Thu Jan 23 2024 Emma Dauris <emma.dauris@netcentric.biz> - %{version}-1
- First build
EOT

# Build the RPM
rpmbuild -ba ~/rpmbuild/SPECS/httpd.spec

echo "RPM Build Complete. Check ~/rpmbuild/RPMS/ for the RPM file."
