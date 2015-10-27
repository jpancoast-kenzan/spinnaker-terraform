
/*
admin subnets:
  3
  4
  5
    Maybe should figure out a better way to do this...

ec2 subnets:
  6
  7
  8
*/

/* bastion instance */
resource "aws_instance" "bastion" {
  ami = "${lookup(var.trusty_amis, var.region)}"
  instance_type = "t2.small"
  subnet_id = "${aws_subnet.public_subnet.3.id}"
  vpc_security_group_ids = ["${aws_security_group.adm_bastion.id}", "${aws_security_group.vpc_sg.id}", "${aws_security_group.mgmt_sg.id}"]
  associate_public_ip_address=true
  key_name = "${var.ssh_key_name}"
  tags = {
    Name = "bastion host"
    created_on = "${var.run_date}"
    created_by = "Kenzan terraform"
  }

  connection {
    user = "${var.ssh_user}"
    key_file = "${var.ssh_private_key_location}"
    agent = false
  }

  provisioner "file" {
    source = "${var.ssh_private_key_location}"
    destination = "/home/${var.ssh_user}/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 0600 /home/${var.ssh_user}/.ssh/id_rsa"
    ]
  }
}

/* jenkins instance */
resource "aws_instance" "jenkins" {
  ami = "${lookup(var.trusty_amis, var.region)}"
  instance_type = "t2.small"
  subnet_id = "${aws_subnet.public_subnet.6.id}"
  vpc_security_group_ids = ["${aws_security_group.infra_jenkins.id}", "${aws_security_group.vpc_sg.id}", "${aws_security_group.mgmt_sg.id}"]
  associate_public_ip_address=true
  key_name = "${var.ssh_key_name}"

  connection {
    user = "${var.ssh_user}"
    bastion_host = "${aws_instance.bastion.public_ip}"
    bastion_user = "${var.ssh_user}"
    key_file = "${var.ssh_private_key_location}"
    host = "${aws_instance.jenkins.private_ip}"
    agent = false
  }


  provisioner "remote-exec" {
    inline = [
      "mkdir -p /tmp/terraform/"
    ]
  }


  provisioner "file" {
    source = "../files/"
    destination = "/tmp/terraform"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod a+x /tmp/terraform/jenkins_provision.sh",
      "sudo /tmp/terraform/jenkins_provision.sh ${var.aptly_repo_key} ${var.jenkins_admin_username} ${var.jenkins_admin_password}"
    ]
  }

  tags = {
    Name = "Jenkins host"
    created_on = "${var.run_date}"
    created_by = "Kenzan terraform"
  }
}

/* Spinnaker instance */
resource "aws_instance" "spinnaker" {
  ami = "${lookup(var.trusty_amis, var.region)}"
  instance_type = "t2.large"
  subnet_id = "${aws_subnet.public_subnet.7.id}"
  vpc_security_group_ids = ["${aws_security_group.infra_spinnaker.id}", "${aws_security_group.vpc_sg.id}", "${aws_security_group.mgmt_sg.id}"]
  associate_public_ip_address=true
  key_name = "${var.ssh_key_name}"
  tags = {
    Name = "Spinnaker host"
    created_on = "${var.run_date}"
    created_by = "Kenzan terraform"
  }
}