resource "google_compute_firewall" "http-jenkins" {
	name = "http-jenkins"

	allow {
		protocol = "tcp"
		ports = ["80"]
	}

	network = "${google_compute_network.spinnaker-network.name}"

	source_ranges = ["38.75.226.18/32"]

	target_tags = ["jenkins-spinnaker"]
}

resource "google_compute_firewall" "ssh-bastion" {
	name = "ssh-bastion"

	allow {
		protocol = "tcp"
		ports = ["22"]
	}

	network = "${google_compute_network.spinnaker-network.name}"

	source_ranges = ["38.75.226.18/32"]

	target_tags = ["bastion"]
}