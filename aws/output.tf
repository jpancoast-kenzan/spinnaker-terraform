#output "Spinnaker user AWS access key" {
#	value = "${aws_iam_access_key.spinnaker.id}"
#}
#
#output "Spinnaker user AWS SECRET key" {
#	value = "${aws_iam_access_key.spinnaker.secret}"
#}
#
#output "Spinnaker Public IP (for DNS)" {
#	value = "${aws_instance.spinnaker.public_ip}"
#}
#
#output "Jenkins Public IP (for DNS)" {
#	value = "${aws_instance.jenkins.public_ip}\n"
#}
#
#output "Bastion Public IP (for DNS)" {
#	value = "${aws_instance.bastion.public_ip}\n"
#}
#
#output "Setup known_hosts on bastion server, this only needs to be done once, but it must be done before the tunneling command will work." {
#	value = "\nssh -o IdentitiesOnly=yes -i ${var.ssh_private_key_location} ${var.ssh_user}@${aws_instance.bastion.public_ip} 'ssh-keyscan -H ${aws_instance.spinnaker.private_ip} > ~/.ssh/known_hosts'\n"
#}
#
#output "SSH tunneling command for Spinnaker" {
#	value = "\nssh -o IdentitiesOnly=yes -i ${var.ssh_private_key_location} -L 8080:localhost:8080 -L 8084:localhost:8084 ${var.ssh_user}@${aws_instance.bastion.public_ip} 'ssh -o IdentitiesOnly=yes -i /home/${var.ssh_user}/.ssh/id_rsa -L 8080:localhost:80 -L 8084:localhost:8084 -A ${var.ssh_user}@${aws_instance.spinnaker.private_ip}'\nNow go to http://localhost:8080/ in your browser.\n"
#}
#

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

#output "testing crap" {
#	value = "I wonder if this works
#	second line
#	blah
#	"
#}