# This document's goal is to log each usefull entry to permit a successfull demonstration of Foreman

## 2017-01-05 - oduquesne
- first setup from basic OS : https://theforeman.org/plugins/katello/nightly/installation/index.html
- fix kafo error with : https://bugzilla.redhat.com/show_bug.cgi?id=1381081
```
    /opt/puppetlabs/puppet/bin/gem install yard
    /opt/puppetlabs/bin/puppet module install puppetlabs-strings
    foreman-installer --scenario katello --enable-foreman-plugin-ansible --enable-foreman-plugin-discovery --enable-foreman-plugin-openscap  --katello-enable-ostree
```
- https://localhost is available from SSH tunnels

## 2017-01-06 - oduquesne
- add filesystems
- disable SELinux
- pulp-admin and usefull script from https://access.redhat.com/solutions/1381053
```
    yum install install glances ethstatus pulp-admin
```
- create user oduquesne
- trash each package (pulp is unavailable from hammer ping , pulp sent 404 error during product addings, there were tasks in error, pulp-admin is in failure too , try to scratch ....
```
    yum remove `rpm -qa | egrep 'katello|puppet|ruby|foreman|pulp|postgre|mongo|tomcat|http'`
    foreman-installer --scenario katello --enable-foreman-plugin-ansible --enable-foreman-plugin-discovery --enable-foreman-plugin-openscap  --katello-enable-ostree
    hammer ping => ok !!!
```
- great, previous configuration still present in database, let's go far away
- add some GPG keys and products : CentOS-7, SCLO, EPEL-7
- sync
- retry admin cmdline
```
    yum install pulp-admin-client.noarch
```

it works too !
```
    pulpAdminPassword=$(grep ^default_password /etc/pulp/server.conf | cut -d' ' -f2)
    pulp-admin -u admin -p $pulpAdminPassword tasks list
    +----------------------------------------------------------------------+
                                     Tasks
    +----------------------------------------------------------------------+
    
    Operations:  
    Resources:   orphans (content_unit)
    State:       Waiting
    Start Time:  Unstarted
    Finish Time: Incomplete
    Task Id:     49d07bb1-ce05-4f96-bae2-0d413a6b5f28
    
    Operations:  sync
    Resources:   Default_Organization-CentOS-7-x86_64-CentOS-7-x86_64 (repository)
    State:       Running
    Start Time:  2017-01-07T00:29:39Z
    Finish Time: Incomplete
    Task Id:     1eaef54b-ca2f-4929-8232-5339a70505aa
    
    Operations:  sync
    Resources:   Default_Organization-EPEL-7-EPEL-7 (repository)
    State:       Running
    Start Time:  2017-01-07T00:31:17Z
    Finish Time: Incomplete
    Task Id:     ffaff0d7-2494-45a6-a277-1f7c37aa80fc
    
    Operations:  publish
    Resources:   Default_Organization-CentOS-7-x86_64-CentOS-7-x86_64-updates
                 (repository)
    State:       Waiting
    Start Time:  Unstarted
    Finish Time: Incomplete
    Task Id:     6a3f5151-9dd6-4a9a-b528-33d572800d6a
    
    Operations:  publish
    Resources:   Default_Organization-CentOS-7-x86_64-CentOS-7-x86_64-sclo
                 (repository)
    State:       Waiting
    Start Time:  Unstarted
    Finish Time: Incomplete
    Task Id:     27ca529c-0cd7-48e1-aa82-ac0e171f1b07
```


## 2017-01-12 - oduquesne
- disk was destroyed : complete reinstall, destroy products failed due to locked task
- `foreman-rake katello:delete_orphaned_content RAILS_ENV=production` to remove orphaned ?
- reinstall scenarii with `--reset` option to drop each databases
- user recreation
- product recreatio n & sync complete with autodiscover function and http exposition : CentOS-7 & EPEL-7


