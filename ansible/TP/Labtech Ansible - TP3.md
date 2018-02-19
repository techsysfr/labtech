Labtech Ansible - TP 3
========================

Dans ce TP 3 on va voir ce que sont les roles dans ansible. Pour cela on va reprendre ce qu'on a fait dans le TP 2 mais au lieu de mettre notre "intelligence" dans le playbook, on va le mettre dans un role **apache**.

## Les roles

http://docs.ansible.com/ansible/latest/playbooks_reuse_roles.html

Exercice : Créer le role **apache**, ranger tout notre bordel dedans et créer un playbook d'installation de notre role.

### Création du role apache

Exercice : Créer le role apache.

Solution :

On pourrait tout créer à la main mais on a une commande qui va travailler à notre place :

```
ansible-galaxy init apache
```

Celle ci va nous créer l'arborescence suivante :

```
.
├── README.md
├── defaults
│   └── main.yml
├── files
├── handlers
│   └── main.yml
├── meta
│   └── main.yml
├── tasks
│   └── main.yml
├── templates
├── tests
│   ├── inventory
│   └── test.yml
└── vars
    └── main.yml
```

Maintenant comment va-t-on ranger tout ça ?

Exercice : **Ranger votre chambre !** Ou dit autrement, mettre les taches au bon endroit, les templates au bon endroit etc...

Solution :

### Les variables 

On peut ranger nos variables soit dans **defaults/main.yml**, soit dans **vars/main.yml**

C'est quoi le mieux ? Bas c'est pas si évident.

La différence vient surtout de l'ordre dans lequel ansible va lire et donc surcharger les variables.

Pour plus d'info sur la question : 
http://docs.ansible.com/ansible/latest/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable

Par défaut on va les mettre dans **defaults/main.yml**

### Les fichiers "brut" à copier

Si on veut copier un fichier, un tarball, un rpm, etc,  et l'envoyer sur notre slave, on doit le stocker dans le répertoire **files**.

Le module copy ira automatiquement le chercher.

### Les fichiers de templating

Pareil pour nos fichiers jinja2 de templating, on les stocke dans le répertoire templates et ansible ira automatiquement les chercher.

### Les handlers

Nos taches handlers on les stocke dans handlers/main.yml

### Les taches

Là pas de surprise on stocke tout dans tasks/main.yml



### Le playbook 

Notre playbook désormais ne va plus avoir qu'à appeler le role apache.

Plus exactement, en appelant le role, il va executer son **tasks/main.yml**

Voila ce que ça donner lorsqu'on crée le fichier **install-apache.yml** : 

```
- hosts: [slave]
  become: yes

  roles:
    - apache
```

C'est tout ? Et oui c'est tout !

Allez on le lance :

```
ansible-playbook -i inventories/hosts install-apache.yml
```

Bingo !