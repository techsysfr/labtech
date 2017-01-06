# Systemd / Overview & Very Quick Troubleshooting

## Overview

### How to see system logs

Before : `tail -F /var/log/messages`
Now : `journalctl -xe`

Before : `dmesg`
Now : `journalctl --list-boots`

If you need to activate persistence, look at /etc/systemd/journald.conf and check you have Storage=auto or persistent.
If auto, create logdir
    mkdir /var/log/journal
    systemctl restart systemd-journald.service

### Play with services

Check system status : 
    systemctl status postfix

Restart mailer
    systemctl restart postfix

Enable a service at boot time
    systemctl enable postfix

Discover services
    systemctl list-units-files | grep service

Masking a service (so you will not able to start or enable it)
    systemctl mask postfix

Backward compatibility : /usr/sbin/service is used as it was systemd, but service list will be stored in /run/systemd/generator

### Troubleshooting

