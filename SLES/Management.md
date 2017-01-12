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


administration

create mirror

## list enabled repos 
`smt-repos -m -o`

## list mirrorable repos
`smt-repos -m -o`

## list products
`smt-list-products`

## activate sles12sp0 sap mirroring
`smt-repos -p SLES_SAP,12,x86_64`

## disable unecessary repos 
```
smt-repos -d SLES12-Debuginfo-Updates sle-12-x86_64
smt-repos -d SLES12-Debuginfo-Pool sle-12-x86_64 
smt-repos -d SLE12-SAP-Debuginfo-Pool sle-12-x86_64
smt-repos -d SLE-HA12-Debuginfo-Updates sle-12-x86_64
smt-repos -d SLE-HA12-Debuginfo-Pool sle-12-x86_64
smt-repos -d SLE-12-SAP-Debuginfo-Updates sle-12-x86_64
```

## effectively sync
```
smt-sync
smt-mirror
```

## to push packages to spacewalk 
```
zypper install rhnpush

/usr/bin/rhnpush -v --server admna1spc10.hosting.eu -u xxx -p xxx  --nosig -c sles-x86_64-server-12-sp1-sap-pool -d /srv/www/htdocs/repo/SUSE/Products/SLE-SAP/12-SP1/x86_64/product/x86_64/

/usr/bin/rhnpush -v --server admna1spc10.hosting.eu -u xxx -p xxx  --nosig -c sles-x86_64-server-12-sp1-sap-pool -d /srv/www/htdocs/repo/SUSE/Products/SLE-SAP/12-SP1/x86_64/product/noarch/
```

# Suse Manager

Tiens le Suse Manager 4 est annoncé !

Source : https://www.suse.com/documentation/suse-manager-3/singlehtml/book_suma3_quickstart_3/book_suma3_quickstart_3.html
