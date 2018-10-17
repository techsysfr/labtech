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

/*
image   = "${var.restored == "true" ? "" : "${data.google_compute_image.my_image.self_link}"}"
*/