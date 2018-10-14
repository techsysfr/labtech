provider "google" {
  credentials = "${var.credentials}"
  
}

terraform {
  backend "gcs" {
    project     = "redoute-infrastructure"
    region      = "eu-west1"
    bucket      = "redoute-infrastructure-terraform"
    prefix      = "dev"
    credentials = "../terraform_key.json"
  }
}

module "project" {
  source          = "../../modules/Project"
  region          = "${var.region}"
  zone            = "${var.zone}"
  project_name    = "${var.project_name}"
  folder_id       = "${var.folder_id}"
  gce_svc_account = "${var.gce_svc_account}"
  image_project   = "${var.image_project}"
  oslogin         = "${var.oslogin}"
}
