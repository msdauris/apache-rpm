archiveBash2
#!/bin/bash

# Specify the version of httpd you want to download
HTTPD_VERSION="2.4.58"
APR_VERSION="1.7.4"
APR_UTIL_VERSION="1.6.3"

# Install necessary development tools and dependencies
yum groupinstall -y "Development Tools"
yum install -y rpm-build wget autoconf libtool doxygen openssl-devel libxml2-devel lua-devel openldap-devel

# Create the rpmbuild directories
mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

# Download the source tarball of the specified version of httpd
wget -P ~/rpmbuild/SOURCES "https://downloads.apache.org/httpd/httpd-$HTTPD_VERSION.tar.gz"

# Download APR
wget "https://downloads.apache.org/apr/apr-1.7.4.tar.gz" -P ~/rpmbuild/SOURCES
if [ $? -ne 0 ]; then
    echo "Failed to download apr-1.7.4.tar.gz"
    exit 1
fi

# Download APR-util
wget "https://downloads.apache.org/apr/apr-util-1.6.3.tar.gz" -P ~/rpmbuild/SOURCES
if [ $? -ne 0 ]; then
    echo "Failed to download apr-util-1.6.3.tar.gz"
    exit 1
fi

# Build and install APR from source
rpmbuild -tb --clean ~/rpmbuild/SOURCES/apr-$APR_VERSION.tar.gz

# Install the built APR and apr-devel packages
rpm -Uvh ~/rpmbuild/RPMS/x86_64/apr-$APR_VERSION-*.x86_64.rpm ~/rpmbuild/RPMS/x86_64/apr-devel-$APR_VERSION-*.x86_64.rpm

# Build and install APR-util with LDAP support
# Extract apr-util
tar xzf ~/rpmbuild/SOURCES/apr-util-$APR_UTIL_VERSION.tar.gz -C ~/rpmbuild/BUILD

# Change directory to the extracted apr-util
cd ~/rpmbuild/BUILD/apr-util-$APR_UTIL_VERSION

# Configure with LDAP support
./configure --prefix=/usr/local/apache2 --with-included-apr --enable-ldap --enable-authnz-ldap
make
make install

# Download and rebuild distcache (adjust the version as necessary)
wget https://archive.fedoraproject.org/pub/archive/fedora/linux/releases/18/Everything/source/SRPMS/d/distcache-1.4.5-23.src.rpm -P ~/rpmbuild/SOURCES
rpmbuild --rebuild --clean ~/rpmbuild/SOURCES/distcache-1.4.5-23.src.rpm

# Install the built distcache and distcache-devel packages
cd ~/rpmbuild/RPMS/x86_64
rpm -Uvh distcache-1.4.5-23.x86_64.rpm distcache-devel-1.4.5-23.x86_64.rpm

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

BuildRequires:  gcc, make, pcre-devel, expat-devel, libxml2-devel, openssl-devel, openldap-devel, lua-devel, apr-devel, apr-util-devel

%description
The Apache HTTP Server, a robust, commercial-grade, featureful, and freely-available source code implementation of an HTTP (Web) server.

%prep
%setup -q -n httpd-%{version}
tar xzf %{SOURCE1} -C srclib/
tar xzf %{SOURCE2} -C srclib/
mv srclib/apr-1.7.4 srclib/apr
mv srclib/apr-util-1.6.3 srclib/apr-util

%build
./configure --prefix=/usr/local/apache2 \
            --with-apr=/usr/lib64/apr-1 \
            --with-apr-util=/usr/lib64/apr-util-1 \
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
