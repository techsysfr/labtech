# TP1

## Fichier State

A la fin du TP0 (Start), vous avez normallement créé votre projet. Si besoin, aller sur console.google.com pour vérfier sa présence.

- Copiez maintenant le fichier main.tf dans un dossier TP1

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

- Relancer maintenant la commande : `terraform apply` qui doit se finir par :

  ```cmd
  Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
  ```

## Projet

### Billing account

Vous avez créé votre projet mais pour l'instant, il est inutilisable car vous n'avez pas spécifié de billing account (obligatoire pour créer des engines par exemple).

Mettre à jour la ligne : `billing_account = "0174AF-BE8A96-2C514B"`

### Folders

Dans l'organisation Techsys, il peut y avoir une hierarchie (arboréscence). Il est possible de préciser dans quel dossier le projet doit se situer. Pour cela, il faut spécifier l'ID du dossier à utiliser.  
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

- Supprimer la ligne: `"org_id": "6892586500",`

- Uploader le fichier modifié et renommer le en `default.tfstate`

- Effectuer un `terraform apply -refresh=false`. Cela évite de récupérer l'état actuel de vos ressources GCP. Attention, à éviter car ça peut engendrer des incohérences.  

  Vous devez à nouveau obtenir une erreur mais cette fois c'est lié à un problème de droit. Pour migrer des projets dans un dossier, il est nécessaire d'obtenir la pemrission `Folder Mover` sur l'organisation. Il est donc nécessaire que je vous ajoute les permissions (ca me permettra de vérifier l'avancée de chacun).

  **pause**

- Effectuer à nouveau la commande :  `terraform apply -refresh=false`.  
  
  La commande fonctionne cette fois.

### Services

Chaque service google nécessite que l'API associée soit activée.  
Pour éviter d'activer l'API manuellement sur la console WEB, vous pouvez activer les API nécessaire gràce à terraform.  

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

  depends_on = ["google_project.project-yourname"] # permet de préciser des dépendences. Ici, cela permet d'attendre la création complète du projet pour activer les API. L'interpolation devrait suffire mais l'ID est surement récupéré avant la fin de l'initialisation du projet.
}
```

Lancer un `terraform apply`

Comme vous le voyez, la liste d'API est assez longue. Au lieu de réutiliser cette liste à chaque nouveau projet, cette liste peut-être créé dans une variable.

__**UTILISATION DES VARIABLES**__

3 types de variables sont disponibles :

- string
- map (dictionnaire)
- list

Créer maintenant un fichier `variables.tf`

Et ajouter :

```HCL
variable "api-activated" {
  description = "List API to activate"
  type = "list"
  default = [
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
}
```

Modifier ensuite le fichier main.tf comme ci-dessous :

```HCL
resource "google_project_services" "project-testmdr" {
  project = "${google_project.project-testmdr.project_id}"   # On retrouve ici l'interpolation : On récupère l'ID à partir de la resource projet qui doit être créé en amont.
  services = "${var.api-activated}"                          # utilisation de la variable.
  depends_on = ["google_project.project-testmdr"]            # permet de préciser des dépendences. Ici, cela permet d'attendre la création complète du projet pour activer les API. L'interpolation devrait suffire mais l'ID est surement récupéré avant la fin de l'initialisation du projet.
}
```

Lancer à nouveau un `terraform apply`. Normalement, aucune nouvelle ressource est à déployer puisqu'il n'y a pas de modifications.

## Network

Afin de créer un réseau utilisable par une engine, il faut créer le VPC et le subnet.

Pour cela, ajouter les informations suivantes dans le fichier `main.tf`:

```HLC
resource "google_compute_network" "vpc_network" {
  name                    = "${var.vpcname}"                                   # utilisation d'une variable pour utiliser le même nom
  auto_create_subnetworks = "false"
  depends_on      = ["google_project_services.project-testmdr"]
}

resource "google_compute_subnetwork" "vpc_subnetwork" {
  name                     = "sub_net_1"
  ip_cidr_range            = "10.224.0.160/28"                                 # Subnet à utiliser en mode CIDR (utiliser votre réseau voir tableau ci-dessous)
  network                  = "${google_compute_network.vpc_network.self_link}" # Interpolation : récupération de l'URL du VPC créé ci-dessus
  region                   = "${var.region}"
  #project                  = "${google_project.project-testmdr.project_id}"           # Interpolation : ID du projet optionel car vous spécifiez le projet dans le block provider.
  private_ip_google_access = "true"                                            # permet d'accéder aux services Google Public sans sortir sur Internet.
  enable_flow_logs = "true"                                                    # active les logs sur ce réseau
}
```

Cidr à modifier en fonction de l'utilisateur :  
Audric : 10.240.0.0/28  
Olivier : 10.240.0.16/28  
Sebastien : 10.240.0.32/28  
Jean : 10.240.0.48/28  
Robin : 10.240.0.64/28  
Jean-François : 10.240.0.80/28  
Aurélien : 10.240.0.96/28  
Loïc : 10.240.0.112/28  
Pierre-Marie : 10.240.0.128/28  
Guillaume : 10.240.0.144/28  
Test : 10.240.0.160/28  

Comme vous le voyez, il faudra aussi rajouter la variable region (type string). Ca nous permettra de la rentrer une seule fois et elle sera utilisée plusieurs fois lors de la création des différentes ressources.  
Vous pouvez récupérer la liste des régions avec la commande suivante :

```cmd
gcloud compute regions list
```  

De préférence, utilisez `europe-west1` = la Belgique = le plus proche.  

Créer aussi la variable vpcname avec la valeur par defaut : "techsys-vpc".  

Lancer maintenant le `terraform apply`

Corriger le nom du subnet pour qu'il match avec le regexp de GCP.

Relancer le `terraform apply` et vérifier qu'il y aura bien 2 nouveaux objets créés.

## Engine

Nous allons maintenant déployer notre première VM. Pour cela, créer un nouveau fichier : engine.tf et ajouter le code :

```HLC
data "google_compute_image" "my_image" {
  project = "techsys-labtech-1"
  family  = "techsys-centos7"
}

locals {
  datetime = "${element(split("T","${replace("${timestamp()}", "-", "")}"), 0)}"
}

resource "google_service_account" "gce_service_account" {               # Service account à créer pour gérer les Engines
  account_id   = "${var.gce_svc_account}"
  display_name = "Compte de service GCE"
  project      = "${google_project.project-testmdr.project_id}"
  depends_on   = ["google_project_services.project-testmdr"]
}

resource "google_compute_disk" "boot" {
  name    = "${var.instance_name}-boot-${local.datetime}"                # Ici, on va construire le nom du disque.
  project = "${google_project.project-testmdr.project_id}"               # Project ID optionel puisqu'on l'utilise dans le block provider
  type    = "${var.disk_type}"
  size    = "${var.disk_size}"
  zone    = "${var.zone}"
  image   = "${data.google_compute_image.my_image.self_link}"            # Interpolation permettant de récupérer l'image centos Techsys du projet labtech-1

  lifecycle {
    ignore_changes  = ["name"]                                           # Cette option permet d'ignorer les changements de nom de la ressource (en cas de restauration par exemple)
    prevent_destroy = false                                              # Cette option évite la suppression lors d'un remove/create lors d'une modification importante
  }
}

resource "google_compute_disk" "data" {                                  # Disque Data
  name = "${var.instance_name}-data-${local.datetime}"
  project = "${google_project.project-testmdr.project_id}"
  type    = "${var.disk_type}"
  size    = "${var.data_disk_size}"
  zone    = "${var.zone}"

  lifecycle {
    ignore_changes  = ["name"]
    prevent_destroy = false
  }
}

resource "google_compute_instance" "instances" {
  name         = "${var.instance_name}"
  zone         = "${var.zone}"
  project = "${google_project.project-testmdr.project_id}"
  machine_type = "${var.machine_type}"

  boot_disk = {
    source      = "${google_compute_disk.boot.name}"
    auto_delete = "false"                                                 # Ne pas supprimer le disque à la suppression de l'instance.
  }

  attached_disk = {
    source = "${google_compute_disk.data.self_link}"
    device_name = "${google_compute_disk.data.name}"
  }

  network_interface = {
    subnetwork         = "${google_compute_subnetwork.vpc_subnetwork.name}"
    subnetwork_project = "${google_project.project-testmdr.project_id}"
    access_config {
      // Ephemeral IP
      network_tier = "STANDARD"                                            # Indique le type de réseau public à utiliser (network tier) : https://cloud.google.com/network-tiers/
    }
  }

  scheduling {
    on_host_maintenance = "MIGRATE"                                        # Indique l'action à réaliser en cas de maintenance
    automatic_restart   = "true"
  }

  service_account = {
    scopes = "${var.api_permissions}"                                      # Indique les permissions sur les API
    email  = "${google_service_account.gce_service_account.email}"         # Interpolation pour récupérer le compte de service créé plus tôt
  }

  allow_stopping_for_update = "true"
  labels                    =  {                                           # Indique les labels
    contact = "dl-infra"
    sla     = "sla-c3"
    env     = "env-dev"
    notes   = "test-terraform"
  }
  tags                      = ["terraform-test"]                           # Indique le tag réseau (utilisé pour le firewall)
}
```

Il sera aussi nécessaire de rajouter les variables suivantes dans le fichier `variables.tf` :

```HLC
variable "gce_svc_account" {
    description = "Service Account Name"
    default = "gce-svc"
}
variable "region" {
  description = "Region where create new ressources"
  default     = "europe-west1"
}

variable "vpcname" {
  description = "Network ID host the shared vpc"
  default     = "techsys-vpc"
}

variable "instance_name" {
  description = "Nom de l'instance"
}

variable "zone" {
  description = "Zone where create new ressources"
  default     = "europe-west1-d"
}

variable "disk_type" {
  description = "Type of disk"
  default     = "pd-standard"  # pd-ssd or pd-standard local-ssd
}

variable "disk_size" {
  description = "Taille du disque de boot en Go"
}

variable "data_disk_size"{
    description = "Taille du disque data en Go"
}

variable "machine_type" {
  description = "Type of machine"
  default     = "n1-standard-1"   # list of machine type https://cloud.google.com/compute/docs/machine-types or custom type : custom-1-1024 (where 1 = VCPU and 1024 = RAM Mo)
}
variable "api_permissions" {
  type        = "list"
  description = "List of API with permissions for the service account"
  default     = ["logging-write", "monitoring-write", "storage-rw", "service-management", "compute-rw", "service-control"]
}
```

## Permission / Role

```HLC
resource "google_project_iam_custom_role" "backup_custom_role" {
  project     = "${google_project.project.project_id}"
  role_id     = "backup_custom_role"
  title       = "backup_custom_role"
  description = "Custom Role permit run snapshot by service account"
  permissions = ["compute.disks.list", "compute.snapshots.list", "compute.disks.createSnapshot", "compute.snapshots.get", "compute.snapshots.create", "compute.snapshots.delete"]
}

resource "google_project_iam_member" "backup_custom_iam" {
  project = "${google_project.project.project_id}"
  role    = "projects/${google_project.project.project_id}/roles/${google_project_iam_custom_role.backup_custom_role.role_id}"
  member  = "serviceAccount:${local.final_gce_svc_account}"
  depends_on = ["google_project_iam_member.project","google_project_iam_custom_role.backup_custom_role"]
}
```