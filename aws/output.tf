output "Spinnaker user AWS access key" {
	value = "${aws_iam_access_key.spinnaker.id}"
}

output "Spinnaker user AWS SECRET key" {
	value = "${aws_iam_access_key.spinnaker.secret}"
}

output "Spinnaker Public IP (for DNS)" {
	value = "${aws_instance.spinnaker.public_ip}"
}

output "Jenkins Public IP (for DNS)" {
	value = "${aws_instance.jenkins.public_ip}"
}

output "Bastion Public IP (for DNS)" {
	value = "${aws_instance.bastion.public_ip}"
}