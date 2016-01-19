Summary: Installs and configures Mcollective.
Name: pupmod-simp-mcollective
Version: 2.3.1
Release: 0
License: Apache License, Version 2.0
Group: Applications/System
Source: %{name}-%{version}-%{release}.tar.gz
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
Requires: puppet >= 3.3.0
Requires: puppetlabs-java_ks >= 1.4.0
Requires: pupmod-richardc-datacat >= 0.6.1
Buildarch: noarch

Prefix: /etc/puppet/environments/simp/modules

%description
Installs and configures Mcollective.

%prep
%setup -q

%build

%install
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/mcollective

dirs='files lib manifests templates'
for dir in $dirs; do
  test -d $dir && cp -r $dir %{buildroot}/%{prefix}/mcollective
done

files='README.simp README.md'
for file in $files; do
  test -f $file && cp $file %{buildroot}/%{prefix}/mcollective
done

%clean
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/mcollective

%files
%defattr(0640,root,puppet,0750)
%{prefix}/mcollective

%post
#!/bin/sh

%postun
# Post uninstall stuff

%changelog
* Mon Jan 18 2015 Nick Markowski <nmarkowski@keywcorp.com> - 2.3.1-0
- Module forked from voxpupuli/puppet-mcollective
  (https://github.com/voxpupuli/puppet-mcollective)
- Added in mco_autokey generation.
