provider "google" {
  project = "techsys-labtech-tf-testmdr1" #optionel : permet uniquement de spécifier le projet qui sera utilisé par défaut lors des appels terraform. On y reviendra dans les autres exercices.
  region = "europe-west1"
  version = "1.18" # force la version à 1.18
}

resource "google_project" "project-testmdr1" {
  name                = "labtech-tf-testmdr1"
  project_id          = "techsys-labtech-tf-testmdr1"
  billing_account     = "" #
  folder_id           = "" #
  auto_create_network = "false" # Evite la création des réseaux par défaut qui ne sont pas nécessaires.
}
