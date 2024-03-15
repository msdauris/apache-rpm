#!/bin/bash

# Specify the versions
HTTPD_VERSION="2.4.58"
APR_VERSION="1.7.4"
APR_UTIL_VERSION="1.6.3"

# Install necessary development tools and dependencies
yum groupinstall -y "Development Tools"
yum install -y wget rpm-build libuuid-devel autoconf libtool doxygen openssl-devel lua-devel libxml2-devel mailcap apr-devel apr-util-devel

# Create the rpmbuild directories
mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

# Download APR and APR-Util source tarballs
for file in "apr-$APR_VERSION.tar.bz2" "apr-util-$APR_UTIL_VERSION.tar.bz2"; do
    wget -P ~/rpmbuild/SOURCES "https://downloads.apache.org/apr/$file"
done

# Download the HTTPD source tarball
wget -P ~/rpmbuild/SOURCES "https://downloads.apache.org/httpd/httpd-$HTTPD_VERSION.tar.bz2"

# Navigate to the SOURCES directory
cd ~/rpmbuild/SOURCES

# Build APR from source
echo "Building APR..."
rpmbuild -tb --clean apr-1.7.4.tar.bz2 || { echo "APR build failed"; exit 1; }

# Navigate to the RPMs directory
cd ~/rpmbuild/RPMS/x86_64

# Check for and install the RPMs
if [ -f "apr-1.7.4-1.x86_64.rpm" ] && [ -f "apr-devel-1.7.4-1.x86_64.rpm" ]; then
    rpm -Uvh apr-1.7.4-1.x86_64.rpm apr-devel-1.7.4-1.x86_64.rpm || { echo "APR installation failed"; exit 1; }
else
    echo "APR RPM files not found. Installation failed."
    exit 1
fi

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

# Create a spec file for httpd
cat <<EOT > ~/rpmbuild/SPECS/httpd.spec
Name:           httpd
Version:        $HTTPD_VERSION
Release:        1%{?dist}
Summary:        Apache HTTP Server

License:        ASL 2.0
URL:            https://httpd.apache.org/
Source0:        https://downloads.apache.org/httpd/httpd-2.4.58.tar.bz2
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
            --with-apr
            --with-apr-util
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
