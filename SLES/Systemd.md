# Systemd / Overview & Very Quick Troubleshooting

## Overview

### How to see system logs

Before : `tail -F /var/log/messages`
Now : `journalctl -xe`

Before : `dmesg`
Now : `journalctl --list-boots`

If you need to activate persistence, look at /etc/systemd/journald.conf and check you have Storage=auto or persistent.
If auto, create logdir
```
    mkdir /var/log/journal
    systemctl restart systemd-journald.service
```

### Play with services

Check system status : 
```
    systemctl status postfix
```

Restart mailer
```
    systemctl restart postfix
```

Enable a service at boot time
```
    systemctl enable postfix
```

Discover services
```
    systemctl list-units-files | grep service
```

Masking a service (so you will not able to start or enable it)
```
    systemctl mask postfix
```

Backward compatibility : /usr/sbin/service is used as it was systemd, but service list will be stored in /run/systemd/generator

### Troubleshooting

Quickly, systemd-analyze can help with

basicly you have just duration booting time

```
    systemd-analyze
```

with blame option, you have each process duration time, then you can use plot option to catch the longest one

```
    systemd-analyze blame
```
You can enjoy graphing options to see failures
```
    systemd-analyze plot > graph.svg
    systemd-analyze dot > out.dot && neato out.dot -Gsep=+20 -Goverlap=false -Tpng -o graph.png
    systemd-analyze --from-pattern powerd.service dot > out.dot && neato out.dot -Gsep=+20 -Goverlap=false -Tpng -o graph_failed_from.png
    systemd-analyze --to-pattern powerd.service dot > out.dot && neato out.dot -Gsep=+20 -Goverlap=false -Tpng -o graph_failed_to.png
```
You can check service dependancies with
```
    systemd-analyze verify

```

### How to boot in single mode

```
    systemctl rescue
```

to come back to a specific target (runlevel in SystemV) or set other booting mode
```
    systemctl isolate default
    systemctl isolate multi-user
    systemctl -t target
    systemctl get-default
```

