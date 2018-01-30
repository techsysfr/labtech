#!/bin/bash

# Users applicatifs
groupadd elasticsearch
groupadd nagios
useradd -d /appl/bgd_elasticsearch1 -g elasticsearch bgd_elasticsearch1 || true
useradd -d /appl/bgd_admin bgd_admin || true
useradd -d /appl/nrpevsc -g nagios nrpevsc || true

mkdir -p /export/appl
ln -s /export/appl /appl

# Install repositories
cat > /etc/yum.repos.d/vsc_repos6-dvd.repo <<EOF
[CENTOS-DVD]
name=centos-dvd
baseurl=http://repo/centos/latest6/x86_64
enabled=1
gpgcheck=1
gpgkey=http://repo/centos/latest6/x86_64/RPM-GPG-KEY-CentOS-6

[SPACEWALK-CLI6]
name=spacewalk-cli6
baseurl=http://repo/repo6/SPACEWALK-CLI6
gpgkey=http://repo/repo6/SPACEWALK-CLI6/RPM-GPG-KEY-spacewalk-2015
gpgcheck=1
enabled=1
EOF

cat > /etc/yum.repos.d/vsc_repos6.repo <<EOF
[VSCADMIN]
name=VSCADMIN
baseurl=http://repo/repo6/vsc/admin
gpgkey=http://repo/repo6/vsc/admin/RPM-GPG-KEY-ExploitationSysteme
enabled=1

[VSCAPP]
name=VSCAPP
baseurl=http://repo/repo6/vsc/app
gpgkey=http://repo/repo6/vsc/admin/RPM-GPG-KEY-ExploitationSysteme
enabled=1

[VSCSUP]
name=VSCSUP
baseurl=http://repo/repo6/vsc/sup
gpgkey=http://repo/repo6/vscadmin/RPM-GPG-KEY-ExploitationSysteme
enabled=1

[VSCCDN]
name=VSCSUP
baseurl=http://repo/repo6/vsc/cdn
gpgkey=http://repo/repo6/vscadmin/RPM-GPG-KEY-ExploitationSysteme
enabled=0

[VSCGIT]
name=VSCGIT
baseurl=http://repo/repo6/vsc/gitlab
gpgkey=http://repo/repo6/vsc/admin/RPM-GPG-KEY-ExploitationSysteme
enabled=0

[EMC]
name=EMC
baseurl=http://repo/repo6/emc
enabled=1

[QLOGIC]
name=QLOGIC
baseurl=http://repo/repo6/qlogic/rhel6
enabled=1

#[FUSIONIO]
#name=FUSIONIO
#baseurl=http://repo/repo6/fusion-io/rhel6
#enabled=1

[EMULEX]
name=EMULEX
baseurl=http://repo/repo6/emulex
enabled=1

[HP]
name=HP
baseurl=http://repo/repo6/hp6
gpgkey=http://repo/repo6/hp6/GPG-KEY-SPP-6 http://repo/repo6/hp6/GPG-KEY-SPP-NEW-6 http://repo/repo6/hp6/GPG-KEY-ServicePackforProLiant
enabled=1

[LSI]
name=LSI
baseurl=http://repo/repo6/lsi
enabled=1

[ORACLE]
name=ORACLE
baseurl=http://repo/repo6/oracle
enabled=1

[EPEL]
name=EPEL
baseurl=http://repo/repo6/EPEL6
gpgkey=http://repo/repo6/EPEL6/RPM-GPG-KEY-EPEL-6
enabled=0
exclude=nrpe*

[IUS]
name=IUS
baseurl=http://repo/repo6/ius6
gpgkey=http://repo/repo6/ius6/IUS-COMMUNITY-GPG-KEY
enabled=0
gpgcheck=1

[PHP55]
name=PHP55
baseurl=http://repo/repo6/php55
gpgkey=http://__repo__/repo6/vscadmin/RPM-GPG-KEY-ExploitationSysteme
gpgcheck=1
enabled=0

[CENTOS65-UPDATES]
name=CENTOS65-UPDATES
baseurl=http://repo/repo6/centos/6.5/updates/x86_64
enabled=0

[VSCSEC]
name=VSCADMIN
baseurl=http://repo/repo6/security
enabled=1

[VMWARE]
name=VMWARE
baseurl=http://repo/repo6/vmware6
gpgkey=http://repo/repo6/vmware6/VMWARE-PACKAGING-GPG-RSA-KEY.pub
enabled=1

[PUPPET]
name=PUPPET
baseurl=http://repo/repo6/puppetlabs-el6
gpgkey=http://repo/repo6/puppetlabs-el6/RPM-GPG-KEY-puppetlabs
enabled=1

[PUPPETDEPS]
name=PUPPETDEPS
baseurl=http://repo/repo6/puppetlabs-el6-deps
gpgkey=http://repo/repo6/puppetlabs-el6/RPM-GPG-KEY-puppetlabs
enabled=1

[GLUSTERFS]
name=GLUSTERFS
baseurl=http://repo/repo6/glusterfs
gpgkey=http://repo/repo6/glusterfs/pub.key
enabled=0
EOF

# Install Ansible depenencies
yum install -y --enablerepo=EPEL libselinux-python software-properties-common ansible
