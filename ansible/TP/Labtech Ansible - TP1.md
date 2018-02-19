Labtech Ansible - TP 1
========================

Dans ce TP 1 on va surtout passer du temps à l'installation d'ansible et voir quelques grand principes.

Installation Ansible
=======

#### Sur le serveur Ansible master

- Installer le paquet ansible depuis les repos :
```
yum install ansible
```
- Créer un user ansible et switcher sur ce user :

```
useradd ansible
su - ansible
```

-  Générer les clés SSH pour ce user :

```
ssh-keygen
```

#### Sur le serveur slave

- Créer le user ansible et échanger les clés ssh avec le user ansible créer précedemment sur le serveur ansible master.
Le serveur ansible doit pouvoir se connecter sur le serveur slave sans demande de mot de passe.

-  Créer une règle sudoers pour permettre au user ansible de passer root sans mot de passe.

```
vi /etc/sudoers.d/10_10_sudo_ansible

ansible ALL=(ALL) NOPASSWD:ALL
```

### Test de l'installation

#### Création du fichier d'inventaire

On créer le fichier **inventories/hosts**, celui-ci contient :

```
[slave]
172.10.0.xx
```

#### Ping en mode ad-hoc

Pour vérifier que le serveur slave est bien attaquable par ansible, on va utiliser le module ping en mode ad-hoc :

```
ansible -i inventoy/hosts -m ping 172.10.0.xx

Si tout va bien ça nous répond un joli "SUCESS"

172.10.0.140 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

Sinon

```
172.10.0.140 | UNREACHABLE! => {
    "changed": false,
    "msg": "Failed to connect to the host via ssh: Permission denied (publickey,gssapi-keyex,gssapi-with-mic,password).\r\n",
    "unreachable": true
}
```

On peut également tester le ping en attaquant le groupe slave :

```
ansible -i inventoy/hosts -m ping slave
```

#### Quelques autres test de modules en mode ad-hoc

- Obtenir le Load Average et l'uptime d'une machine ?

Le module shell permet d'executer une commande shell à distance

```
ansible -i inventoy/hosts -m shell -a "uptime" slave

172.10.0.140 | SUCCESS | rc=0 >>
 16:23:03 up 7 days, 39 min,  4 users,  load average: 0,00, 0,01, 0,05
```

- Installer le paquet http via yum ?
 
```
ansible -i inventories/hosts -m yum -a "name=httpd state=latest" slave

172.10.0.140 | FAILED! => {
    "changed": true,
    "msg": "You need to be root to perform this command.\n",
    "rc": 1,
    "results": [
        "Loaded plugins: fastestmirror\n"
    ]
}
```
Bas pourquoi ça fail ???

Parce que lorsqu'on execute une command via ansible celle ci est executée avec le user grace auquel on se connecte. 
Celui ci n'étant pas root, il ne peux pas executer une commande "appartenant" à root.

Bas pourtant le user ansible est dans les sudoers ?

Pour obtenir les droits de délégation root grace à la règle sudo créée précédemment, il faut utiliser l'option --become


```
ansible -i inventories/hosts -m yum -a "name=httpd state=latest" --become slave

172.10.0.140 | SUCCESS => {
    "changed": true,
    "msg": "",
    "rc": 0,
    "results": [
        "Loaded plugins: fastestmirror\nLoading mirror speeds from cached hostfile\n * base: centos.mirror.ate.info\n * epel: mirror.freethought-internet.co.uk\n * extras: centos.mirror.ate.info\n * updates: rep-centos-fr.upress.io\nResolving Dependencies\n--> Running transaction check\n---> Package httpd.x86_64 0:2.4.6-67.el7.centos.6 will be installed\n--> Processing Dependency: httpd-tools = 2.4.6-67.el7.centos.6 for package: httpd-2.4.6-67.el7.centos.6.x86_64\n--> Processing Dependency: /etc/mime.types for package: httpd-2.4.6-67.el7.centos.6.x86_64\n--> Processing Dependency: libaprutil-1.so.0()(64bit) for package: httpd-2.4.6-67.el7.centos.6.x86_64\n--> Processing Dependency: libapr-1.so.0()(64bit) for package: httpd-2.4.6-67.el7.centos.6.x86_64\n--> Running transaction check\n---> Package apr.x86_64 0:1.4.8-3.el7_4.1 will be installed\n---> Package apr-util.x86_64 0:1.5.2-6.el7 will be installed\n---> Package httpd-tools.x86_64 0:2.4.6-67.el7.centos.6 will be installed\n---> Package mailcap.noarch 0:2.1.41-2.el7 will be installed\n--> Finished Dependency Resolution\n\nDependencies Resolved\n\n================================================================================\n Package           Arch         Version                     Repository     Size\n================================================================================\nInstalling:\n httpd             x86_64       2.4.6-67.el7.centos.6       updates       2.7 M\nInstalling for dependencies:\n apr               x86_64       1.4.8-3.el7_4.1             updates       103 k\n apr-util          x86_64       1.5.2-6.el7                 base           92 k\n httpd-tools       x86_64       2.4.6-67.el7.centos.6       updates        88 k\n mailcap           noarch       2.1.41-2.el7                base           31 k\n\nTransaction Summary\n================================================================================\nInstall  1 Package (+4 Dependent packages)\n\nTotal download size: 3.0 M\nInstalled size: 10 M\nDownloading packages:\n--------------------------------------------------------------------------------\nTotal                                              2.4 MB/s | 3.0 MB  00:01     \nRunning transaction check\nRunning transaction test\nTransaction test succeeded\nRunning transaction\n  Installing : apr-1.4.8-3.el7_4.1.x86_64                                   1/5 \n  Installing : apr-util-1.5.2-6.el7.x86_64                                  2/5 \n  Installing : httpd-tools-2.4.6-67.el7.centos.6.x86_64                     3/5 \n  Installing : mailcap-2.1.41-2.el7.noarch                                  4/5 \n  Installing : httpd-2.4.6-67.el7.centos.6.x86_64                           5/5 \n  Verifying  : mailcap-2.1.41-2.el7.noarch                                  1/5 \n  Verifying  : httpd-2.4.6-67.el7.centos.6.x86_64                           2/5 \n  Verifying  : apr-util-1.5.2-6.el7.x86_64                                  3/5 \n  Verifying  : apr-1.4.8-3.el7_4.1.x86_64                                   4/5 \n  Verifying  : httpd-tools-2.4.6-67.el7.centos.6.x86_64                     5/5 \n\nInstalled:\n  httpd.x86_64 0:2.4.6-67.el7.centos.6                                          \n\nDependency Installed:\n  apr.x86_64 0:1.4.8-3.el7_4.1                  apr-util.x86_64 0:1.5.2-6.el7   \n  httpd-tools.x86_64 0:2.4.6-67.el7.centos.6    mailcap.noarch 0:2.1.41-2.el7   \n\nComplete!\n"
    ]
}
```

Qu'est ce qui se passe si vous execute à nouveau la même commande dans la foulée ?

```
172.10.0.140 | SUCCESS => {
    "changed": false,
    "msg": "",
    "rc": 0,
    "results": [
        "All packages providing httpd are up to date",
        ""
    ]
}
```

On peut voir que le statut "changed" est passé à false. Ce qui correspond à un ok.

C'est ça l'indempotence !

#### Premier playbook

Executer des commandes ad-hoc c'est rigolo mais tout l'interet d'ansible est d'orchestrer cela dans des scénario.

Voila ce qu'on peut faire avec un playbook ansible :

On crée le fichier yaml test.yml :

```
- hosts: [slave]
  become: yes
  tasks:
    - name: Install httpd package
      yum:
        name: httpd
        state: latest

    - name: Show uptime
        shell: "uptime"
```

On l'execute : 

```
ansible-playbook -i inventories/hosts test.yml

PLAY [slave] ********************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************
ok: [172.10.0.140]

TASK [Install httpd package] ****************************************************************************************************
changed: [172.10.0.140]

TASK [Show uptime] **************************************************************************************************************
changed: [172.10.0.140]

PLAY RECAP **********************************************************************************************************************
172.10.0.140               : ok=3    changed=2    unreachable=0    failed=0
```

Et voila !

Quelques option bonus :

L'option **--check** permet de simuler l'execution d'un playbook.
Les options **-v, -vv, -vvvv** permettent de rendre l'affichage de l'execution plus verbeuse.
L'option **--diff** permet de montrer les différences sur un fichier par exemple au moment de l'execution. Pour ça il faut que le module le supporte. 

FIN