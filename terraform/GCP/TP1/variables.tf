variable "credentials" {
  description = "Zone where create new ressources"
  default     = "../terraform_key.json"
}

variable "project_name" {
  description = "Name of project to create"
  type        = "string"
}

variable "region" {
  description = "Region where create new ressources"
  default     = "eu-west-1"
}

variable "zone" {
  description = "Zone where create new ressources"
  default     = "eu-west-1-d"
}

variable "folder_id" {
  description = "Folder ID where create project"
  default     = "363874289672"
}

variable "gce_svc_account" {
  description = "GCE Service Account"
  default     = "gce-svcaccount"
}

variable "image_project" {
  description = "Project ID of the Image project to use"
  default     = "redoute-infrastructure"
}

variable "oslogin" {
  description = "OS Login activation on Project ? Will be a booleen !"
  default     = true
}
