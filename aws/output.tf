
resource "template_file" "output" {
	filename = "../files/output.tpl"

	vars {
		jenkins_public_ip = "${aws_instance.jenkins.public_ip}"
		bastion_public_ip = "${aws_instance.bastion.public_ip}"
		bastion_ip = "${aws_instance.bastion.public_ip}"
		private_key = "${var.ssh_private_key_location}"
		spinnaker_ip = "${aws_instance.spinnaker.private_ip}"
		ssh_user = "${var.ssh_user}"
	}
}

output "" {
	value = "${template_file.output.rendered}"
}