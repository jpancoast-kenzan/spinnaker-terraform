resource "google_compute_network" "spinnaker-network" {
    name = "spinnaker-network"
    ipv4_range = "${var.network_cidr}"
}