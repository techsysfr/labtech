/* resource "google_folder" "rootfolder" {
  display_name = "${var.rootfolder_name}"
  parent       = "organizations/${var.org_id}"
}

resource "google_folder" "subfolder" {
  display_name = ${var.subfolder_name}
  parent       = "${google_folder.rootfolder.name}"
}
*/

resource "google_project" "project" {
  name                = "${var.project_name}"
  project_id          = "redoute-${lower(var.project_name)}"
  billing_account     = "${var.billing_account}"
  folder_id           = "${var.folder_id}"
  auto_create_network = "false"
}

resource "google_compute_shared_vpc_service_project" "service_project" {
  count = "${var.is_shared_vpc == "true" ? 1 : 0}"
  host_project    = "${var.shared_vpc_project}"
  service_project = "${google_project.project.project_id}"
  depends_on      = ["google_project_services.project"]
}


resource "google_project_services" "project" {
  project = "${google_project.project.project_id}"

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

  depends_on = ["google_project.project"]
}

resource "google_compute_shared_vpc_service_project" "service_project" {
  count = "${var.is_shared_vpc == "true" ? 1 : 0}"
  host_project    = "${var.shared_vpc_project}"
  service_project = "${google_project.project.project_id}"
  depends_on      = ["google_project_services.project"]
}

/*
data "google_compute_network" "vpc_network" {
  name    = "${var.vpcname}"
  project = "${var.is_shared_vpc == "true" ? var.shared_vpc_project : google_project.project.project_id}"
}
*/
resource "google_compute_network" "vpc_network" {
  name                    = "${var.vpcname}"
  auto_create_subnetworks = "false"
  depends_on      = ["google_project_services.project"]
}

resource "google_compute_subnetwork" "vpc_subnetwork" {
  count = "${var.subnetname != "" ? 1 : 0}"
  name                     = "${var.subnetname}"
  ip_cidr_range            = "${var.subnetcidr}"
  network                  = "${google_compute_network.vpc_network.self_link}"
  region                   = "${var.region}"
  project                  = "${var.is_shared_vpc == "true" ? var.shared_vpc_project : google_project.project.project_id}"
  private_ip_google_access = "true"
  enable_flow_logs = "true"
}

resource "google_compute_project_metadata_item" "default" {
  key        = "enable-oslogin"
  value      = "${var.oslogin ? "TRUE" : "FALSE"}"
  project    = "${google_project.project.project_id}"
  depends_on = ["google_project_services.project"]
}

resource "google_service_account" "gce_service_account" {
  account_id   = "${var.gce_svc_account}"
  display_name = "Compte de service GCE"
  project      = "${google_project.project.project_id}"
  depends_on   = ["google_project_services.project"]
}

resource "google_project_iam_member" "project" {
  project    = "${var.image_project}"
  role       = "roles/compute.imageUser"
  member     = "serviceAccount:${local.final_gce_svc_account}"
  depends_on = ["google_project_services.project"]
}

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

/*
resource "google_project_iam_member" "engine_admin" {
  count   = "${length(var.roles)}"
  project = "${google_project.project.project_id}"

  #role       = "${var.roles[count.index]}"
  role       = "${element(var.roles, count.index)}"
  member     = "group:${var.os_admin_group}"
  depends_on = ["google_project_services.project"]
}
*/


/*
resource "google_project_iam_member" "engine_user" {
  count   = "${length(var.roles)}"
  project = "${google_project.project.project_id}"

  #role       = "${var.roles[count.index]}"
  role       = "${element(var.roles, count.index)}"
  member     = "group:${var.os_admin_group}"
  depends_on = ["google_project_services.project"]
}
*/

