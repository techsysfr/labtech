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