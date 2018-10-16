
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

variable "fw_default_priority" {
  description = "FW Default priority"
  default     = "1000"
}

/*


variable "zone" {
  description = "Zone where create new ressources"
  default     = "europe-west1-d"
}

variable "disk_type" {
  description = "Type of disk"
  default     = "pd-standard"  # pd-ssd or pd-standard local-ssd
}

variable "image_project" {
  description = "Project ID of the Image project to use"
  default     = "techsys-infrastructure"
}




variable "api_permissions" {
  type        = "list"
  description = "List of API with permissions for the service account"
  default     = ["logging-write", "monitoring-write", "storage-rw", "service-management", "compute-rw", "service-control"]
}

variable "rolesAdmins" {
  description = "Roles to gives of the OS Admin Group"
  default     = ["roles/compute.osAdminLogin", "roles/compute.viewer", "roles/iam.serviceAccountUser"]
}

variable "rolesUsers" {
  description = "Roles to gives of the OS Admin Group"
  default     = ["roles/compute.osLogin", "roles/iam.serviceAccountUser"]
}

locals {
  final_gce_svc_account = "${var.gce_svc_account}@${google_project.project.project_id}.iam.gserviceaccount.com"
}
*/