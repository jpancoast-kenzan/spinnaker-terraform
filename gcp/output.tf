
resource "template_file" "output" {
	template = "output.tpl"

	vars {
		region = "${var.region}"
		kenzan_statepath = "${var.kenzan_statepath}"
		network = "${google_compute_network.spinnaker-network.name}"
		bastion_ip = "${google_compute_instance.bastion.network_interface.0.access_config.0.nat_ip}"
		private_key = "${var.ssh_private_key_location}"
		ssh_user = "${var.ssh_user}"
		zone = "${var.zone}"
	}
}

output "" {
	value = "${template_file.output.rendered}"
}