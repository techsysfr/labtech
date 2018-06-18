# Suse Live Patching

## First install kgraft
You must install an extension (with subscription) to install it
```
yast / software / Add extension
select Suse Linux Enterprise Live Patching 12
Accept Licence
Install kgraft
Finish
```
## Reboot your system
Reboot your SLES

## Quick admin
Show available patches
```
    zypper list-patches
```

Show a specifi patch
```
zypper patch-info SUSE-SLE-SERVER-12-SP1-2017-3
Rafraichissement du service 'SMT-http_adsl-172-10-1-29'.
Chargement des données du dépôt...
Lecture des paquets installés...

Informations sur patch SUSE-SLE-SERVER-12-SP1-2017-3 :
------------------------------------------------------
Nom : SUSE-SLE-SERVER-12-SP1-2017-3
Version : 1
Arch : noarch
Fabricant : maint-coord@suse.de
État : Nécessaire
Catégorie : security
Sévérité :moderate
Créé le : lun. 02 janv. 2017 08:37:00 CET
Redémarrage requis : Non
Redémarrage du gestionnaire de paquets requis: Non
État interactif : Non
Résumé : Security update for zlib
Description : 

This update for zlib fixes the following issues:
CVE-2016-9843: Big-endian out-of-bounds pointer (bsc#1013882)
CVE-2016-9842: Undefined Left Shift of Negative Number (bsc#1003580)
CVE-2016-9840 CVE-2016-9841: Out-of-bounds pointer arithmetic in inftrees.c (bsc#1003579)

Incompatible declarations for external linkage function deflate (bsc#1003577)

Trouvé(es):
patch:SUSE-SLE-SERVER-12-SP1-2017-3 == 1
Conflits:
libz1.x86_64 < 1.2.8-6.3.1
srcpackage:zlib < 1.2.8-6.3.1
libz1-32bit.x86_64 < 1.2.8-6.3.1
```

Check your system first
```
zypper patch-check
Rafraichissement du service 'SMT-http_adsl-172-10-1-29'.
Chargement des données du dépôt...
Lecture des paquets installés...
394 patches needed (147 security patches)
```

Check your kernel version
```
uname -a
Linux adsl-172-10-1-36 3.12.49-11-default #1 SMP Wed Nov 11 20:52:43 UTC 2015 (8d714a0/kGraft-8b8f2e8) x86_64 x86_64 x86_64 GNU/Linux
```

## Patch your system
Then patch your system
```
zypper patch
```

Now you can patch your system, let's play again with `zypper patch`
```
zypper patch
```
You have more than 500 patches to install !

We were surprised we had to reboot !


```
zypper patch-check
Rafraîchissement du service 'SMT-http_adsl-172-10-1-29'.
Chargement des données de l'espace de stockage...
Lecture des paquetages installés...
0 patches needed (0 security patches)
```

# kgraft management
```
    kgr status
    kgr patches
```

# Install a specific patch only
```
zypper patch --cve CVE-2015-8215                                                                                                                                                       
Rafraîchissement du service 'SMT-http_adsl-172-10-1-29'.
Chargement des données de l'espace de stockage...
Lecture des paquetages installés...
Résolution des dépendances de paquetages…

The following 2 NEW packages are going to be installed:
  kernel-default-3.12.67-60.64.24.1 kgraft-patch-3_12_67-60_64_24-default

The following 2 NEW patches are going to be installed:
  SUSE-SLE-SERVER-12-SP1-2015-985 SUSE-SLE-SERVER-12-SP1-2016-329

The following 2 patches require a system reboot:
  SUSE-SLE-SERVER-12-SP1-2015-985 SUSE-SLE-SERVER-12-SP1-2016-329

2 new packages to install.
Taille de téléchargement globale : 33,6 MiB. Déjà mis en cache : 0 B. Après l'opération, un 139,7 MiB supplémentaire sera utilisé.
Le système doit être redémarré.
continuer ? [o/n/? affiche toutes les options] (o): 
```
# Lien vers la doc Lifecycle
https://www.suse.com/support/policy.html
