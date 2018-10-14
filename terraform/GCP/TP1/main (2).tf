provider "google" {
  #credentials = "${var.credentials}"
  project = "redoute-newmf-stg"
  region = "europe-west1"
}

terraform {
  backend "gcs" {
    project = "redoute-infrastructure"
    region  = "eu-west1"
    bucket  = "redoute-infrastructure-terraform"
    prefix  = "newmf-stg"              # to change for each project

    #credentials = "../terraform_key.json"
  }
}

######################## PROJECT ########################

module "project" {
  source        = "../modules/project"
  region        = "${var.region}"
  zone          = "${var.zone}"
  project_name  = "newmf-stg"        # without "redoute-" will be add for the project id
  folder_id     = "104699713239"           # id of the folder where the project will be created
  image_project = "${var.image_project}"       # project ID where image are hosted (in our case : redoute-infrastructure) 
  is_shared_vpc = "no"                         # project using shared vpc or his own vpc
  vpcname = "vpc-be"
  subnetname    = "newmf-stg-sub-01"
  subnetcidr    = "10.234.0.0/24"
  oslogin       = "true"                       # Add the oslogin metadata on the project (true or false)
}

resource "google_project_iam_member" "engine_admins" {
  count   = "${length(var.rolesAdmins)}"
  project = "${module.project.project_id}"
  role    = "${element(var.rolesAdmins, count.index)}"
  member  = "group:admin_newmf-stg_instance@redoute.com"
}

resource "google_project_iam_member" "engine_users" {
  count   = "${length(var.rolesUsers)}"
  project = "${module.project.project_id}"
  role    = "${element(var.rolesUsers, count.index)}"
  member  = "group:user_newmf-stg_instance@redoute.com"
}

resource "google_service_account" "newmf-jenkins" {
  account_id   = "newmf-jenkins"
  display_name = "NEWMF Jenkins Admin"
  project      = "${module.project.project_id}"
}

resource "google_project_iam_member" "jenkin_admin" {
  count   = "${length(var.rolesAdmins)}"
  project = "${module.project.project_id}"
  role    = "${element(var.rolesJenkins, count.index)}"
  member  = "serviceAccount:${google_service_account.newmf-jenkins.email}"
}

######################## VPN ########################

module "vpn" {
  source        = "../modules/vpn"
  region        = "${var.region}"
  secret-vpn-evea = "f36KA-xPvVg"  
  secret-vpn-kering = "8godHRgfgfSaf44cdm"
  public-ip-name-vpn-kering = "vpn-1-tunnel1" # optional : use the default variable instead of
  public-ip-description-vpn-kering = "VPN Kering" # optional : use the default variable instead of
  public-ip-description-vpn-evea = ["VPN 10.0.0.0/9","VPN 192.168.0.0/16"] # optional : use the default variable instead of
  route-vpn-evea-10 = ["10.0.0.0/9"]
  create-vpn-kering = "true"
  vpcname = "${module.project.network}"
  project = "${module.project.project_id}"
  subnet = ["10.234.0.0/24"]
}