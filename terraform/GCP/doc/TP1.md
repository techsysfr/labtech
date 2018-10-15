# TP1

## Fichier State

A la fin du TP0 (Start), vous avez normallement créé votre projet. Si besoin, aller sur console.google.com pour vérfier sa présence.

- Copiez maintenant le fichier main.tf dans le dossier TP1

- Positionnez-vous dans le dossier TP1 et lancer `terraform plan`

  Vous obtenez une erreur car vous avez changé de dossier. Il faut à nouveau effectuer un `terraform init`

- Lancez tout de suite un `terraform apply`

  Terraform affiche qu'il va à nouveau créer le projet... Tiens bizarre.  
  Approuver.  

  Vous obtenez alors une erreur car le projet exist déjà.  
  Pourquoi donc terraform a voulu le créer à nouveau ?  
  C'est parce que le fichier d'état n'existe plus (il se trouve dans le dossier TP0).  

### terraform import

Puisque votre projet existe déjà mais que votre fichier state est maintenant inexistant ou vide, il faut importer votre projet dans le fichier state.

Pour cela, il faut utiliser la commande : `terraform import`

- Lancer la commande :

```cmd
terraform import google_project.project-yourname  techsys-labtech-tf-yourname
google_project.project-yourname: Importing from ID "techsys-labtech-tf-yourname"...
google_project.project-yourname: Import complete!
  Imported google_project (ID: techsys-labtech-tf-yourname)
google_project.project-yourname: Refreshing state... (ID: techsys-labtech-tf-yourname)

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.
```

- Tenter à un nouveau d'appliquer votre configuration avec un `terraform apply`  
  Cette fois terraform ne détecte qu'une modification : `auto_create_network` car cette valeur n'est pas récupérée lors de l'importation. Approuver la modification.

- Si vous relancer à nouveau un `terraform apply`, terraform ne détectera plus aucunes modifications.

### Fichier state partagé

#### Explications

Comme vous l'avez vu, lorsque le fichier state est local, cela implique plusieurs problèmatiques :

- Le fichier peut-être supprimé ou perdu en changeant de dossier, poste, etc..

- Lorsque plusieurs personnes travaillent sur le même projet, il est nécessaire d'avoir un fichier state commun.

- Il est important de locker le fichier state lors de modifitions simultanées.

Pour cela, terraform permet de positionner le fichier state sur différent supports.

L'un qui permet de faire du lock est le bucket Google : Google Cloud Storage.

#### Configuration state partagé

- Modifier le fichier main.tf et ajouter :

```HLC
terraform {
  backend "gcs" {
    project = "techsys-infrastructure"           # nom du projet qui héberge le bucket
    region  = "eu-west1"
    bucket  = "techsys-infrastructure-terraform" # nom du bucket
    prefix  = "yourname"                         # A changer pour chaque project terraform
  }
}
```

- Lancer à nouveau un terraform init pour initiliser le fichier state sur le bucket:

```cmd
terraform init
```

Lors de l'initialisation, terraform demande si vous voulez repartir d'un fichier state vide ou copier le fichier local.  
Entrer "yes" pour copier l'état actuel de votre projet.  

- Vous pouvez maintenant supprimer les fichiers terraform.tfstate et terraform.tfstate.backup situés sans le dossier TP1.
  Pi : voici comment configurer le versionning sur un bucket GCP : `gsutil versioning set on gs://techsys-infrastructure-terraform`

- Relancer maintenant la commande : `terraform apply` qui doit se finir :

  ```cmd
  Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
  ```

## Projet

### Billing account

Vous avez créé votre projet mais pour l'instant, il est inutilisable car vous n'avez pas spécifié de billing account (obligatoire pour créer des engines par exemple).

Mettre à jour la ligne : `billing_account = "0174AF-BE8A96-2C514B"`

### Folders

Dans l'organisation Techsys, il peut y avoir une hierarchie (arboréscence). Il est possible de préciser dans quel dossier le projet doit se situer. Pour cela, il faut spécifier l'ID du dossier à utiliser :  
Dans notre cas, le project doit se situer dans l'arborescence : techsys/Labtech/Terraform.
Voici l'ID à utliser : 875105072392  

Mettre à jour la ligne : `folder_id = "875105072392"`

Vous devez avoir finalement :

```HLC
resource "google_project" "project-yourname" {
  name                = "labtech-tf-yourname"
  project_id          = "techsys-labtech-tf-yourname"
  billing_account     = "0174AF-BE8A96-2C514B" #
  folder_id           = "875105072392" #
  auto_create_network = "false" # Evite la création des réseaux par défaut qui ne sont pas nécessaires.
}
```

Appliquez les modifications avec un `terraform apply` (normallement il s'agit d'un update in-place).  
Vous devriez obtenir une erreur lors de l'application du folder_id : `'org_id' and 'folder_id' cannot be both set`.
Il s'agit en fait d'un des nombreux bugs terraform. Ici, vous ne pouvez pas configurer un org_id et un folder_id pour un projet. Vous avez cette erreur car un projet est créé par défaut avec un org_id lorsqu'aucun dossier n'est spécifié. Maintenant que vous rajoutez un paramètre folder_id, il faut supprimer l'org_id mais comment faire puisqu'il avait été configuré par défaut ? --> Le fichier state.

- Allez sur le [bucket.](https://console.cloud.google.com/storage/browser/techsys-infrastructure-terraform)

- Télécharger le fichier .tfstate

- Supprimer la ligne: `"org_id": "6892586500",` et modifier la ligne `"folder_id": "875105072392"`

- Uploader le fichier modifié et renommer le en `default.tfstate`

- Effectuer un `terraform apply -refresh=false`. Cela évite de récupérer l'état actuel de vos ressources GCP. Attention, à éviter car ça peut engendrer des incohérences.  

  Vous devez à nouveau obtenir une erreur mais cette fois c'est lié à un problème de droit. Pour migrer des projets, il est nécessaire d'obtenir la pemrission `Folder Mover` sur l'organisation. Il est donc nécessaire que je vous ajoute les permissions (ca me permettra de vérifier l'avancée de chacun).

  **pause**

- Effectuer à nouveau la commande :  `terraform apply -refresh=false`.  
  
  La commande fonctionne cette fois.

### Services

Chaque service google nécessite que l'API associée soit activée.  
Pour éviter d'activer l'API manuellement sur la console WEB, vous pouvez activer ces API gràce à terraform.  

Voici ci-dessous le bloc à ajouter au fichier main.tf :

```HLC
resource "google_project_services" "project-yourname" {
  project = "${google_project.project-yourname.project_id}"   # On retrouve ici l'interpolation : On récupère l'ID à partir de la resource projet qui doit être créé en amont.

  services = [
    "compute.googleapis.com",
    "iam.googleapis.com",
    "cloudapis.googleapis.com",
    "cloudbilling.googleapis.com",
    "clouddebugger.googleapis.com",
    "cloudtrace.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "servicemanagement.googleapis.com",
    "storage-api.googleapis.com",
    "storage-component.googleapis.com",
    "bigquery-json.googleapis.com",
    "sql-component.googleapis.com",
    "oslogin.googleapis.com",
    "datastore.googleapis.com",
    "serviceusage.googleapis.com",
    "containerregistry.googleapis.com",
    "file.googleapis.com",
    "pubsub.googleapis.com",
    "deploymentmanager.googleapis.com",
    "replicapool.googleapis.com",
    "replicapoolupdater.googleapis.com",
    "resourceviews.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "container.googleapis.com",
    "stackdriver.googleapis.com"
  ]

  depends_on = ["google_project.project"] # permet de préciser des dépendences. Ici, cela permet d'attendre la création complète du projet pour activer les API. L'interpolation devrait suffire mais l'ID est surement récupéré avant la fin de l'initialisation du projet.
}
```

## Network

## Engine