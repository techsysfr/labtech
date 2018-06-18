# SMT

Source : https://www.suse.com/documentation/sles-12/book_smt/data/smt_installation.html

##  register to scc
`SUSEConnect --debug -e <email> -r <id>`

## updates
`zypper update`
`init 6`

## install pattern smt
`zypper in -t pattern smt`

## configure smt
`yast smt-server`

=> set user/pass of scc organisation
=> set password for smt mysql base 
=> set password for mysql root
=> run CA mgmt
=> set a CA passwd


`yast smt`
administration

create mirror

## list enabled repos 
`smt-repos -m -o`

## list mirrorable repos
`smt-repos -m -o`

## list products
`smt-list-products`

## activate sles12sp0 sap mirroring
```
smt-repos -p SLES,12.2,x86_64
smt-repos -p suse-openstack-cloud,7,x86_64
smt-repos -p suse-openstack-cloud,6,x86_64
smt-repos -p sle-live-patching,12,x86_64
```


## disable unecessary repos 
```
smt-repos | grep '^| Yes' |egrep 'Debug|Source'
smt-repos | grep '^| Yes' |egrep 'Debug|Source' | while read pipe yes pipe nb pipe nu pipe chan trash; do 
echo a | smt-repos -d $chan
done
```

## effectively sync
```
smt-sync
smt-mirror
```

## disable forward regstration
set false to specific option at `/etc/smt.con`

## client registration
Edit /etc/SUSEConnect as example, disable security, set your SMT host

## sync your operating system from SMT Server
We first synced SLES 12SP2 but our client were on SLES 12SP1, Registration failed with this error
`Error: SCC returned 'Product not (fully) mirrored on this server' (422)`

We added its own repos and synced from SMT, then registration from client occured
`Registered SLES 12.1 x86_64`
`To server: http://<hostname>`

## to push packages to spacewalk 
```
zypper install rhnpush

/usr/bin/rhnpush -v --server admna1spc10.hosting.eu -u xxx -p xxx  --nosig -c sles-x86_64-server-12-sp1-sap-pool -d /srv/www/htdocs/repo/SUSE/Products/SLE-SAP/12-SP1/x86_64/product/x86_64/

/usr/bin/rhnpush -v --server admna1spc10.hosting.eu -u xxx -p xxx  --nosig -c sles-x86_64-server-12-sp1-sap-pool -d /srv/www/htdocs/repo/SUSE/Products/SLE-SAP/12-SP1/x86_64/product/noarch/
```

# Suse Manager

Tiens le Suse Manager 4 est annoncé !

Source : https://www.suse.com/documentation/suse-manager-3/singlehtml/book_suma3_quickstart_3/book_suma3_quickstart_3.html
