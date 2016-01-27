
resource "template_file" "output" {
	template = "output.tpl"

	vars {
		jenkins_public_ip = "${aws_instance.jenkins.public_ip}"
		bastion_public_ip = "${aws_instance.bastion.public_ip}"
		bastion_ip = "${aws_instance.bastion.public_ip}"
		private_key = "${var.ssh_private_key_location}"
		spinnaker_private_ip = "${aws_instance.spinnaker.private_ip}"
		jenkins_private_ip = "${aws_instance.jenkins.private_ip}"
		ssh_user = "${var.ssh_user}"
		sg_id = "${aws_security_group.example_app.id}"
		vpc_sg_id = "${aws_security_group.vpc_sg.id}"
		mgmt_sg_id = "${aws_security_group.mgmt_sg.id}"
		vpc_name = "${var.vpc_name}"
		aws_region = "${var.region}"
		vpc_id = "${aws_vpc.main.id}"
		instance_iam_role = "${var.base_iam_role_name}"
		kenzan_statepath = "${var.kenzan_statepath}"
	}
}

output "" {
	value = "${template_file.output.rendered}"
}