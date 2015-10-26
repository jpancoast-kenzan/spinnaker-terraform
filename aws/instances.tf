
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

  provisioner "file" {
    source = "../files/nginx_jenkins.conf"
    destination = "/tmp/nginx_jenkins.conf"
  }

  provisioner "file" {
    source = "../files/provision_base_ami"
    destination = "/tmp/provision_base_ami"
  }

  provisioner "file" {
    source = "../files/config.xml"
    destination = "/tmp/config.xml"
  }

  provisioner "remote-exec" {
    inline = [
      "wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -",
      "sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'",
      "sudo sh -c 'echo deb http://repo.aptly.info/ squeeze main > /etc/apt/sources.list.d/aptly.list'",
      
      "sudo  apt-key adv --keyserver keys.gnupg.net --recv-keys E083A3782A194991", #VARIABLIZE THE KEY FINGERPRINT
      "sudo apt-get update",
      "sudo apt-get -y install jenkins",
      "sudo apt-get -y install aptly",

      "sudo mkdir -p /var/lib/jenkins/jobs/dsl-ami-provisioning/",
      "sudo mv /tmp/config.xml /var/lib/jenkins/jobs/dsl-ami-provisioning/",

      "sudo chown jenkins:jenkins /var/lib/jenkins/jobs/",
      "sudo chown jenkins:jenkins /var/lib/jenkins/jobs/* -R",

      "sudo update-rc.d jenkins enable",
      "sudo /etc/init.d/jenkins start",
      "sudo apt-get -y install nginx",
      "sudo mv /tmp/nginx_jenkins.conf /etc/nginx/sites-available/default",
      "sudo mv /tmp/provision_base_ami /usr/bin/",
      "sudo apt-get install unzip",

      "curl -L https://dl.bintray.com/mitchellh/packer/packer_0.8.6_linux_amd64.zip > /tmp/packer.zip",
      "cd /tmp/ ; sudo unzip /tmp/packer.zip -d /usr/bin",
      
      "sudo mkdir -p /var/lib/jenkins/updates",
      "sudo chown jenkins:jenkins /var/lib/jenkins/updates/",
      "sudo chmod 0755 /var/lib/jenkins/updates/",
      "curl -L https://updates.jenkins-ci.org/update-center.json | sed '1d;$d' > /var/lib/jenkins/updates/default.json",
      "sudo mv /tmp/default.json /var/lib/jenkins/updates/default.json",
      "sudo chown jenkins:jenkins /var/lib/jenkins/updates/default.json",
      "sudo chmod 0755 /var/lib/jenkins/updates/default.json",
      "cd /opt/;sudo wget -q http://localhost:8080/jnlpJars/jenkins-cli.jar",

      "/usr/bin/java -jar /opt/jenkins-cli.jar -s http://localhost:8080/ install-plugin chucknorris",
      "/usr/bin/java -jar /opt/jenkins-cli.jar -s http://localhost:8080/ install-plugin git",
      "/usr/bin/java -jar /opt/jenkins-cli.jar -s http://localhost:8080/ install-plugin github-api",
      "/usr/bin/java -jar /opt/jenkins-cli.jar -s http://localhost:8080/ install-plugin github",
      "/usr/bin/java -jar /opt/jenkins-cli.jar -s http://localhost:8080/ install-plugin git-parameter",
      "/usr/bin/java -jar /opt/jenkins-cli.jar -s http://localhost:8080/ install-plugin job-dsl",
      "/usr/bin/java -jar /opt/jenkins-cli.jar -s http://localhost:8080/ install-plugin parameterized-trigger",
      "/usr/bin/java -jar /opt/jenkins-cli.jar -s http://localhost:8080/ install-plugin shelve-project-plugin",
      "/usr/bin/java -jar /opt/jenkins-cli.jar -s http://localhost:8080/ install-plugin ssh",
      "/usr/bin/java -jar /opt/jenkins-cli.jar -s http://localhost:8080/ install-plugin swarm",
      "/usr/bin/java -jar /opt/jenkins-cli.jar -s http://localhost:8080/ install-plugin credentials-binding",
      "/usr/bin/java -jar /opt/jenkins-cli.jar -s http://localhost:8080/ install-plugin workflow-step-api",
      "/usr/bin/java -jar /opt/jenkins-cli.jar -s http://localhost:8080/ install-plugin ws-cleanup",
      "/usr/bin/java -jar /opt/jenkins-cli.jar -s http://localhost:8080/ install-plugin plain-credentials",
      "/usr/bin/java -jar /opt/jenkins-cli.jar -s http://localhost:8080/ install-plugin postbuildscript.jpi",

      "sudo update-rc.d nginx enable",
      "sudo /etc/init.d/nginx restart",
      "sudo /etc/init.d/jenkins restart"
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