#resource "google_compute_firewall" "http-jenkins" {
#	name = "http-jenkins"
#
#	allow {
#		protocol = "tcp"
#		ports = ["80"]
#	}
#
#	network = "${google_compute_network.spinnaker-network.name}"
#
#	source_ranges = ["38.75.226.18/32"]
#
#	target_tags = ["jenkins-spinnaker"]
#}

resource "google_compute_firewall" "http-7070" {
	name = "http-7070"

	allow {
		protocol = "tcp"
		ports = ["7070"]
	}

	network = "${google_compute_network.spinnaker-network.name}"

	source_ranges = ["0.0.0.0/0"]
	target_tags = ["http-7070-server"]
}

resource "google_compute_firewall" "bastion-to-spinnaker" {
	name = "bastion-to-spinnaker"

	allow {
		protocol = "tcp"
		ports = ["22"]
	}

	network = "${google_compute_network.spinnaker-network.name}"

	source_tags = ["bastion", "spinnaker-and-jenkins"]
}

resource "google_compute_firewall" "ssh-bastion" {
	name = "ssh-bastion"

	allow {
		protocol = "tcp"
		ports = ["22"]
	}

	network = "${google_compute_network.spinnaker-network.name}"

	source_ranges = ["${compact(concat(split(",",var.local_ip),split(",",var.adm_bastion_incoming_cidrs)))}"]

	target_tags = ["bastion"]
}

resource "google_compute_firewall" "aptly-access" {
	name = "aptly-access"

	allow {
		protocol = "tcp"
		ports = ["9999"]
	}

	network = "${google_compute_network.spinnaker-network.name}"

	source_ranges = ["${var.network_cidr}"]
	target_tags = ["spinnaker-and-jenkins"]
}

#resource "google_compute_firewall" "packer-access" {
#	name = "packer-access"
#
#	allow {
#		protocol = "tcp"
#		ports = ["22"]
#	}
#
#	network = "${google_compute_network.spinnaker-network.name}"
#
#	source_tags = ["spinnaker-and-jenkins"]
#}
