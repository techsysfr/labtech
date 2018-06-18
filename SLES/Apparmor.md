# Apparmor

## Official documentation

http://wiki.apparmor.net/index.php/Profiling_with_tools

## Preparation

List filtered files & daemon
```
    apparmor_status
```

Configuration stays in
```
    /etc/apparmor.d
```

To create your own profile
```
    genprof /usr/bin/evolution
```
let's play with it and check configuration file

## With Yast

```
    yast apparmor
```
You can manage profile and set permissions (read,write,link, ....)

## Disable apparmor (you should not do that !)

```
    aa-disable <your application>
```
You can stop service with systemctl but kernel module is still loaded, you can help yourself with `yast apparmor`


