Labtech Ansible - TP 2
========================

Dans ce TP 2 on va s'attarder sur quelques modules et pousser un peu plus loin le principe d'idempotence.

## Les modules

En reprenant ce qu'on a fait dans le TP1, voici quelques exercices sur quelques modules assez incontournables :

### Le module yum

http://docs.ansible.com/ansible/latest/yum_module.html

Exercice : Installer le package httpd sur votre client avec yum.


Solution : 

```
- hosts: [slave]
  become: yes
  tasks:
    - name: Instaler le paquet httpd
      yum:
        name: httpd
        state: latest
```


### Le module copy

http://docs.ansible.com/ansible/latest/copy_module.html

Exercice : On doit aller déposer un fichier httpd.conf modifié (on change le port d'écoute par exemple) sur notre VM slave.


Solution : 

```
- hosts: [slave]
  become: yes
  tasks:
    - name: Modifier le fichier httpd.conf
      copy:
        src: "httpd.conf"
        dest: "/etc/httpd/conf/httpd.conf"
```

Autre solution pour modifier ce fichier, utiliser les modules **lineinfile**, **blockinfile**, ou **replace**

**lineinfile** :
http://docs.ansible.com/ansible/latest/lineinfile_module.html

**blockinfile**:
http://docs.ansible.com/ansible/latest/blockinfile_module.html

**replace**:
http://docs.ansible.com/ansible/latest/replace_module.html

### Le module Template

Encore une autre solution, c'est de faire du fichier httpd.conf un template.

http://docs.ansible.com/ansible/latest/template_module.html

Exercice: Changer le port d'écoute de notre apache en utilisant une valeur stockée dans une variable.


Solution : 

1. Dans notre playbook, on ajoute un bloc vars pour y stocker notre variable :

```
  vars:
    apache_port: 8081
```

2. On copie un fichier **httpd.conf** vierge existant, on le dépose au même que notre playbook et on l'appelle **httpd.conf.j2** .

Pour info : C'est un fichier jinja2. Jinja2 est le moteur de template du langage python.
http://docs.ansible.com/ansible/latest/playbooks_templating.html#templating-jinja2

On va dans notre httpd.conf.j2, et on modifie notre port d'écoute en le remplaçant par notre variable apache_port en la mettant entre {{ }}

Ce qui donne :

```
#Listen 80
Listen {{ apache_port }}
```

Il ne reste plus qu'à créer la tache dans le playbook.

```
    - name: Modifier le port apache via templating
      template:
        src: "httpd.conf.j2"
        dest: "/etc/httpd/conf/httpd.conf"
```

Au final notre playbook ressemble à ça :

```
- hosts: [slave]
  become: yes

  vars:
    apache_port: 8080

  tasks:
    - name: Install httpd package
      yum:
        name: httpd
        state: latest

    - name: template
      template:
        src: "httpd.conf.j2"
        dest: "/etc/httpd/conf/httpd.conf"
```

On l'exécute :

```
ansible-playbook -i inventories/hosts install-apache.yml
```

Bingo !

### Le module Service

http://docs.ansible.com/ansible/latest/service_module.html

Maintenant qu'on a installé et configuré notre apache il peut etre interessant de le démarrer ou reloader sa conf.

Yum installe automatiquement un fichier de service (init.d ou systemd selon l'os).

On a juste à nous en servir. 

```
- name: Restart apache
    service:
      name: httpd
      state: restarted
      enabled: yes
```
On appelle le service httpd et on veut qu'à la fin il soit redémarré. 

On ajoute l'option **enabled: yes** pour qu'il soit executé au démarrage sur serveur (c'est l'équivalent d'un *chkconfig httpd on* ou *systemctl enable httpd.service*)

Désormais notre playbook ressemble à ça :

```
- hosts: [slave]
  become: yes

  vars:
    apache_port: 8081

  tasks:
    - name: Install httpd package
      yum:
        name: httpd
        state: latest

    - name: template
      template:
        src: "httpd.conf.j2"
        dest: "/etc/httpd/conf/httpd.conf"

   - name: Restart apache
       service:
         name: httpd
         state: restarted
         enabled: yes
```

On l'exécute encore ainsi :

```
ansible-playbook -i inventories/hosts install-apache.yml
```

Que se passe-t-il si on l'exécute à nouveau ? On se rend compte que la tache de service reste à l'état changed.

C'est bien mais pas top car notre playbook n'est pas indempotent.

Une bonne pratique est de déclencher le restart du service httpd si et seulement si sa conf a été modifiée.

Pour ça on va utiliser les handlers.

#### Les handlers

http://docs.ansible.com/ansible/latest/playbooks_intro.html#handlers-running-operations-on-change

Les handlers dans ansible permettent de déclencher une action si une tache passe avec l'état changed.

Dans notre cas l'idéal serait que notre apache soit redémarré si le fichier /etc/httpd/conf/httpd.conf a été modifié via la tache de templating.

Ca va se passer en deux étapes :

1. On ajoute une instruction **notify** à la fin de notre tache de templating. Ce notify appellera le handler "**Restart apache**" si la tache se termine avec le statut changed.

```
    - name: template
      template:
        src: "httpd.conf.j2"
        dest: "/etc/httpd/conf/httpd.conf"
      notify: "Restart apache"
```

2. On crée un bloc **handlers** dans lequel on va créer des taches. Ici on crée la tache **Restart apache**

```
  handlers:
    - name: Restart apache
      service:
        name: httpd
        state: restarted
        enabled: yes
```

Voici notre playbook dans sa version finale :

```
- hosts: [slave]
  become: yes

  vars:
    apache_port: 8080

  tasks:
    - name: Install httpd package
      yum:
        name: httpd
        state: latest

    - name: template
      template:
        src: "httpd.conf.j2"
        dest: "/etc/httpd/conf/httpd.conf"
      notify: "Restart apache"

  handlers:
    - name: Restart apache
      service:
        name: httpd
        state: restarted
        enabled: yes
```

Si on l'execute plusieurs fois de suite on s'aperçoit que toutes les taches sont à l'état OK.

Bravo ! Ce playbook est indempotent.

