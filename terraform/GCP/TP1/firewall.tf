resource "google_compute_firewall" "external-access" {
  name        = "external-access"
  project     = "${google_project.project-testmdr.project_id}"                       # project ID of the host shared vpc project
  network     = "${google_compute_network.vpc_network.self_link}"
  direction   = "INGRESS"
  description = "External Access"
  priority    = "${var.fw_default_priority}"

  source_ranges = [
    "0.0.0.0/0"
  ]

  target_tags = ["terraform-test"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  allow {
      protocol = "icmp"
  }
}