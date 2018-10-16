provider "google" {
  project = "techsys-labtech-tf-testmdr4" #optionel : permet uniquement de spécifier le projet qui sera utilisé par défaut lors des appels terraform. On y reviendra dans les autres exercices.
  region = "europe-west1"
  version = "1.18" # force la version à 1.18
  credentials = "${file("C:\\Users\\mdrouet\\Desktop\\test.json")}"
}

resource "google_project" "project-testmdr4" {
  name                = "labtech-tf-testmdr4"
  project_id          = "techsys-labtech-tf-testmdr4"
  billing_account     = "" #
  org_id           = "6892586500" #
  auto_create_network = "false" # Evite la création des réseaux par défaut qui ne sont pas nécessaires.
}