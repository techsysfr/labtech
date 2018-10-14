#Découverte Terraform

Dans cette partie, on va installer terraform et les pré-requis pour pouvoir créer un serveur.

*Terraform automatise le déploiement de ressources*   

*__Terraform utilise un language descriptif et non évènementiel__*


## Installation de Terraform
Terraform se présente sous forme d'un unique binaire (écrit en Go)
Pour le téléchargement se rendre sur https://www.terraform.io/downloads.html.  
Et choisir le selon son votre OS.  
Mettre le binaire dans votre PATH.  

Pour vérifier que votre installation est correct: `terraform version`  
Vous devez avoir avoir une réponse du style `Terraform v0.11.7`

## Pré-requis AWS
Comme nous allons déployer des ressources sur AWS, nous allons devoir faire en sorte que terraform s'authentifie sur AWS. Pour cela nous allons utiliser les access_key et secret_key.   
Connecter sur la console aws avec vos identifiants que vous avez déjà eu normalement.   
Aller sur la partie IAM et sur Users.  
Selectionner votre user et dans l'onglet Security Credentials, cliquez sur Create access key

__Le couple access_key, secret_key est lié à votre user et donc à les même droits__

## Premier déploiement
Alors on va enfin rentrer dans le vif du sujet.

Terraform va prendre en compte tous les fichiers qui se trouve dans le répertoire courant. Il ne fait de récursif.

La première chose à faire est de configurer un provider. Ce qui nous permet de s'authenitifier et notre mettre à disposition différents type de ressource. Il existe une multitude de provider (https://www.terraform.io/docs/providers/index.html).

provider.tf
```hcl
# Configure the AWS Provider
provider "aws" {
  access_key = "{Votre ACCESS KEY}"
  secret_key = "{Votre SECRET KEY}"
  region     = "us-east-1"
}
```

Il existe d'autres attributs à ce provider, [RTFM](https://www.terraform.io/docs/providers/aws/index.html) ;-)


Nous allons maintenant décrire le serveur que l'on veut.

Instance.tf
```hcl
resource "aws_instance" "server1" {
  ami           = "ami-afd15ed0"    # AMI AWS linux region us-esat-1
  instance_type = "t2.micro"        # TYpe d'instance
  subnet_id     = "subnet-0ae12250" # subnet us-east-1a
}
```

Maintenant que notre description est faite , nous pouvons exécuter terraform  
On commence par `terraform init` à faire à chaque première fois pour initialiser le répertoire.  
Ensuite on continue avec `terraform plan` qui permet de voir ce que terraform va faire.  
Une fois que le plan passe , on peut faire `terraform apply`

Et si vous avez tout suivi vous devez avoir à la fin du apply ceci :
```
aws_instance.server1: Creation complete after 39s (ID: i-0a630425aa84d98d5)

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

Mais comme il manque un Security Group et une Key pair,  on ne peut pas se connecter dessus.

Pour finir cette partie , on va supprimer ce que l'on vient de créer.  
Pour cela `terraform destroy`

*__La suite au prochain episode.__*
