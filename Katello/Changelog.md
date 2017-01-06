# This document's goal is to log each usefull entry to permit a successfull demonstration of Foreman

## 2017-01-05 - oduquesne
- first setup from basic OS : https://theforeman.org/plugins/katello/nightly/installation/index.html
- fix kafo error with : https://bugzilla.redhat.com/show_bug.cgi?id=1381081
    /opt/puppetlabs/puppet/bin/gem install yard
    /opt/puppetlabs/bin/puppet module install puppetlabs-strings
    foreman-installer --scenario katello --enable-foreman-plugin-ansible --enable-foreman-plugin-discovery --enable-foreman-plugin-openscap  --katello-enable-ostree
- https://localhost is available from SSH tunnels

## 2017-01-06 - oduquesne
- add filesystems
- disable SELinux
-   yum install install glances ethstatus pulp-admin
- create user oduquesne
- trash each package (pulp is unavailable from hammer ping , pulp sent 404 error during product addings, there were tasks in error, pulp-admin is in failure too , try to scratch ....
    yum remove `rpm -qa | egrep 'katello|puppet|ruby|foreman|pulp|postgre|mongo|tomcat|http'`
    foreman-installer --scenario katello --enable-foreman-plugin-ansible --enable-foreman-plugin-discovery --enable-foreman-plugin-openscap  --katello-enable-ostree
    hammer ping => ok !!!
- formidable tout est encore là
- ajout des clés GPG et produits pour CentOS-7, SCLO, EPEL-7
- sync

