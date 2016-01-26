
/* bastion instance */
resource "aws_instance" "bastion" {
  ami = "${lookup(var.aws_ubuntu_amis, format(\"%s-%s-%s-%s-%s\", var.region, var.ubuntu_distribution, var.ubuntu_architecture, var.ubuntu_virttype, var.ubuntu_storagetype))}"
  instance_type = "${var.bastion_instance_type}"
  subnet_id = "${aws_subnet.admin_public_subnet.0.id}"
  vpc_security_group_ids = ["${aws_security_group.adm_bastion.id}", "${aws_security_group.vpc_sg.id}", "${aws_security_group.mgmt_sg.id}"]
  associate_public_ip_address=true
  key_name = "${var.ssh_key_name}"
  tags = {
    Name = "bastion host"
    created_by = "${var.created_by}"
  }

  connection {
    user = "${var.ssh_user}"
    key_file = "${var.ssh_private_key_location}"
    agent = false
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /tmp/terraform/"
    ]
  }

  provisioner "file" {
    source = "../files/bastion/"
    destination = "/tmp/terraform"
  }

  provisioner "file" {
    source = "${var.ssh_private_key_location}"
    destination = "/home/${var.ssh_user}/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 0600 /home/${var.ssh_user}/.ssh/id_rsa",
      "chmod a+x /tmp/terraform/provision.sh",
      "/tmp/terraform/provision.sh ${var.ssh_user}"
    ]
  }
}

/* jenkins instance */
resource "aws_instance" "jenkins" {
  ami = "${lookup(var.aws_ubuntu_amis, format(\"%s-%s-%s-%s-%s\", var.region, var.ubuntu_distribution, var.ubuntu_architecture, var.ubuntu_virttype, var.ubuntu_storagetype))}"
  instance_type = "${var.jenkins_instance_type}"
  subnet_id = "${aws_subnet.admin_public_subnet.0.id}"
  vpc_security_group_ids = ["${aws_security_group.infra_jenkins.id}", "${aws_security_group.vpc_sg.id}", "${aws_security_group.mgmt_sg.id}"]
  associate_public_ip_address=true
  key_name = "${var.ssh_key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.jenkins_instance_profile.id}"

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
    source = "../files/aws/jenkins/"
    destination = "/tmp/terraform"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod a+x /tmp/terraform/provision.sh",
      "sudo /tmp/terraform/provision.sh ${var.jenkins_admin_username} ${var.jenkins_admin_password} ${var.ppa_repo_key} ${var.packer_url}"
    ]
  }

  provisioner "local-exec" {
    command = "ssh -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -i ${var.ssh_private_key_location} ${var.ssh_user}@${aws_instance.bastion.public_ip} 'ssh-keyscan -H ${aws_instance.jenkins.private_ip} >> ~/.ssh/known_hosts'"
  }

  tags = {
    Name = "Jenkins host"
    created_by = "${var.created_by}"
  }
}

/* Spinnaker instance */
resource "aws_instance" "spinnaker" {
  ami = "${lookup(var.aws_spinnaker_amis, format(\"%s-%s\", var.region, var.ubuntu_virttype))}"
  instance_type = "${var.spinnaker_instance_type}"
  subnet_id = "${aws_subnet.admin_public_subnet.1.id}"
  vpc_security_group_ids = ["${aws_security_group.infra_spinnaker.id}", "${aws_security_group.vpc_sg.id}", "${aws_security_group.mgmt_sg.id}"]
  associate_public_ip_address=true
  key_name = "${var.ssh_key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.spinnaker_instance_profile.id}"

  connection {
    user = "${var.ssh_user}"
    bastion_host = "${aws_instance.bastion.public_ip}"
    bastion_user = "${var.ssh_user}"
    key_file = "${var.ssh_private_key_location}"
    host = "${aws_instance.spinnaker.private_ip}"
    agent = false
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /tmp/terraform/"
    ]
  }

  provisioner "file" {
    source = "../files/lib/"
    destination = "/tmp/terraform"
  }

  provisioner "file" {
    source = "../files/aws/spinnaker/"
    destination = "/tmp/terraform"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod a+x /tmp/terraform/provision.sh",
      "sudo /tmp/terraform/provision.sh ${var.region} ${var.internal_dns_zone} ${var.jenkins_admin_username} ${var.jenkins_admin_password}"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "chmod a+x /home/ubuntu/.init-region",
      "/home/ubuntu/.init-region",
      "echo init region done.",
      "sudo service spinnaker restart"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "chmod a+x /tmp/terraform/create_application.sh",
      "/tmp/terraform/create_application.sh ${var.region} ${aws_vpc.main.id} ${var.base_iam_role_name} ${var.vpc_name} ${aws_security_group.example_app.id} ${aws_security_group.vpc_sg.id} ${aws_security_group.mgmt_sg.id}"
    ]
  }

  provisioner "local-exec" {
    command = "ssh -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -i ${var.ssh_private_key_location} ${var.ssh_user}@${aws_instance.bastion.public_ip} 'ssh-keyscan -H ${aws_instance.spinnaker.private_ip} >> ~/.ssh/known_hosts'"
  } 

  provisioner "local-exec" {
    command = "ssh -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -i ${var.ssh_private_key_location} ${var.ssh_user}@${aws_instance.bastion.public_ip} 'sed -i.bak -e \"s/<INTERNAL_DNS>/${aws_instance.spinnaker.private_ip}/\" /home/ubuntu/.ssh/config'"
  }
  
  provisioner "remote-exec" {
    inline = [
      "rm -rf /tmp/terraform*"
    ]
  }
  tags = {
    Name = "Spinnaker host"
    created_by = "${var.created_by}"
  }
}
