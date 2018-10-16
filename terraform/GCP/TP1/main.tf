provider "google" {
  project = "techsys-labtech-tf-testmdr" #optionel : permet uniquement de spécifier le projet qui sera utilisé par défaut lors des appels terraform. On y reviendra dans les autres exercices.
  region = "europe-west1"
  version = "1.18" # force la version à 1.18
}

resource "google_project" "project-testmdr" {
  name                = "labtech-tf-testmdr"
  project_id          = "techsys-labtech-tf-testmdr"
  billing_account     = "0174AF-BE8A96-2C514B" #
  folder_id           = "875105072392" #
  auto_create_network = "false" # Evite la création des réseaux par défaut qui ne sont pas nécessaires.
}

terraform {
  backend "gcs" {
    project = "techsys-infrastructure"           # nom du projet qui héberge le bucket
    region  = "eu-west1"
    bucket  = "techsys-infrastructure-terraform" # nom du bucket
    prefix  = "testmdr"                         # A changer pour chaque project terraform
  }
}

resource "google_project_services" "project-testmdr" {
  project = "${google_project.project-testmdr.project_id}"   # On retrouve ici l'interpolation : On récupère l'ID à partir de la resource projet qui doit être créé en amont.
  services = "${var.api-activated}"
  depends_on = ["google_project.project-testmdr"] # permet de préciser des dépendences. Ici, cela permet d'attendre la création complète du projet pour activer les API. L'interpolation devrait suffire mais l'ID est surement récupéré avant la fin de l'initialisation du projet.
}

resource "google_compute_network" "vpc_network" {
  name                    = "${var.vpcname}"                                   # utilisation d'une variable pour utiliser le même nom
  auto_create_subnetworks = "false"
  depends_on      = ["google_project_services.project-testmdr"]
}

resource "google_compute_subnetwork" "vpc_subnetwork" {
  name                     = "sub-net-1"
  ip_cidr_range            = "10.224.0.160/28"                                 # Subnet à utiliser en mode CIDR (utiliser votre réseau voir tableau ci-dessous)
  network                  = "${google_compute_network.vpc_network.self_link}" # Interpolation : récupération de l'URL du VPC créé ci-dessus
  region                   = "${var.region}"
  #project                  = "${google_project.project-testmdr.project_id}"           # Interpolation : ID du projet optionel car vous spécifiez le projet dans le block provider.
  private_ip_google_access = "true"                                            # permet d'accéder aux services Google Public sans sortir sur Internet.
  enable_flow_logs = "true"                                                    # active les logs sur ce réseau
}

resource "google_project_iam_custom_role" "backup_custom_role" {
  project     = "${google_project.project-testmdr.project_id}"
  role_id     = "backup_custom_role"
  title       = "backup_custom_role"
  description = "Custom Role permit run snapshot by service account"
  permissions = ["compute.disks.list", "compute.snapshots.list", "compute.disks.createSnapshot", "compute.snapshots.get", "compute.snapshots.create", "compute.snapshots.delete"]
}

resource "google_project_iam_member" "backup_custom_iam" {
  project = "${google_project.project-testmdr.project_id}"
  role    = "projects/${google_project.project-testmdr.project_id}/roles/${google_project_iam_custom_role.backup_custom_role.role_id}"
  member  = "serviceAccount:${google_service_account.gce_service_account.email}"
  depends_on = ["google_project_iam_custom_role.backup_custom_role"]
}