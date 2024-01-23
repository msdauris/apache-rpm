%define name httpd
%define version 2.4.58
%define release 1

Summary: Apache HTTP Server
Name: %{name}
Version: %{version}
Release: %{release}
Source0: %{name}-%{version}.tar.gz
License: Apache License, Version 2.0
Group: System Environment/Daemons
URL: http://httpd.apache.org/

BuildRequires: apr-devel, apr-util-devel, pcre-devel, openssl-devel

%description
The Apache HTTP Server is a powerful, efficient, and extensible web server.

%prep
%setup -q -n %{name}-%{version}

%build
%configure
make

%install
make install DESTDIR=%{buildroot}

%files
%doc README
%{_sbindir}/httpd
%{_mandir}/man8/httpd.8*
%{_sysconfdir}/httpd

%clean
rm -rf %{buildroot}

%changelog
* Mon Jan 22 2024 Your Name <emma.dauris@netcentric.biz> - %{version}-%{release}
- Initial build.

