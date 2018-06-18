# YAST

## Prerequistes

Start a VM from our internal lab
Choose SUSE Template
Use your favorite Terminal to connect to SSH gateway
Connect as root user to your VM

*Optional : change language to avoid bad translation*
    export LANG=C

## Discover Yast

Launch yast
```
   yast2
```

### Install Software

#### Use Software menu in ncurse interface
   Software / Software Management / Search
Search for `tmux`: you should actually not see it
Search `iftop`, use the right pannel, select `iftop`, use space or enter key to add entrie then use ALT+A to accept manifest


#### Add Extensions as Suse Cloud, Suse Storage
    Softwarre / Add a Product / Extensions and Modules from Registration Server / ALT+N
    Filling up with your adress

Note : your registration will show available licences, you could see nothing here

#### Add a specific repository (openbuild service for example)
If you want to install a specific package not provided by Suse (as COPR on Fedora)
    Software / Add Product / URL
*Repository Name : Open Build Service
URL : http://download.opensuse.org/repositories/utilities/SLE-12-SP1/*

Press ALT+N to add discovered repository, Trust GPG key, then search again for `tmux`

Yeeha ! Install it !

### Tune your system

    System / Boot Loader : where you can modify some GRUB2 options or entries
    System / Date & Time : connect it to NTP servers

ALT+S : other settings
ALT+S : Synchronize to NTP servers instead of Manually, check run and save,
Synchronize now to confirm your parameters and enable it

Now try with commandline, exist Yast

```
    yast -l
    yast ntp-client / Security Settings / Open firewall ports
    yast ntp-client help
    yast ntp-client status
    yast ntp-client list
    yast ntp-client disable
    yast ntp-client enable 
```

    System / Kernel KDump : Check Enable

    System / Network

Edit etc to fix IP address ....

To disable IPv6, go to Global Options and uncheck `Enable IPv6` then reboot

    System / Lang : change language and eventually keymap when you are connected with a QWERTY keyboard through a VMWare console ....

    Security and Users / User and Group Management : where you can add a techsys user

then you can delegate roles via sudo

    Security and Users / Firewall : disable firewall, you have a great Networke team !

