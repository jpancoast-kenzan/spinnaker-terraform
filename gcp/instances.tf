resource "google_compute_instance" "bastion" {
	name = "bastion"
	machine_type = "${var.bastion_machine_type}"
	zone = "${var.region}-${var.zone}"

	tags = ["bastion"]

	disk {
		image = "${var.ubuntu_image}"
	}

	connection {
    user = "${var.ssh_user}"
  	key_file = "${var.ssh_private_key_location}"
  	agent = false
  }

	network_interface {
		network = "${google_compute_network.spinnaker-network.name}"
		access_config {
			nat_ip
		}
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

resource "google_compute_instance" "spinnaker-and-jenkins" {
	name = "spinnaker-and-jenkins"
	machine_type = "${var.spinnaker_machine_type}"
	zone = "${var.region}-${var.zone}"

	tags = ["spinnaker-and-jenkins"]

	disk {
		image = "marketplace-spinnaker-release/${var.spinnaker_image}"
	}

	metadata_startup_script = "/opt/spinnaker/install/first_google_boot.sh"

	service_account {
		scopes = ["compute-rw","storage-rw"]
	}

	network_interface {
		network = "${google_compute_network.spinnaker-network.name}"
		access_config {
			nat_ip
		}
	}

	connection {
		user = "${var.ssh_user}"
		bastion_host = "${google_compute_instance.bastion.network_interface.0.access_config.0.nat_ip}"
		bastion_user = "${var.ssh_user}"
		key_file = "${var.ssh_private_key_location}"
		host = "${google_compute_instance.spinnaker-and-jenkins.network_interface.0.address}"
		agent = false
	}

  provisioner "remote-exec" {
    inline = [
    		"mkdir -p /tmp/terraform/"
  	]
  }

  provisioner "file" {
    source = "../files/gcp/spinnaker-and-jenkins/"
  	destination = "/tmp/terraform"
	}

  provisioner "file" {
    source = "../files/lib/"
  	destination = "/tmp/terraform"
	}

  provisioner "remote-exec" {
    inline = [
      "chmod a+x /tmp/terraform/provision.sh",
  		"chmod a+x /tmp/terraform/create_application.sh",
      "sudo /tmp/terraform/provision.sh ${google_compute_network.spinnaker-network.name} ${var.jenkins_admin_username} ${var.jenkins_admin_password}",
  		"/tmp/terraform/create_application.sh ${var.region} ${var.zone} ${google_compute_network.spinnaker-network.name} ${google_compute_firewall.http-7070.name}"
  	]
  }
	
	provisioner "local-exec" {
    command = "ssh -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -i ${var.ssh_private_key_location} ${var.ssh_user}@${google_compute_instance.bastion.network_interface.0.access_config.0.nat_ip} 'sed -i.bak -e \"s/<INTERNAL_DNS>/${google_compute_instance.spinnaker-and-jenkins.network_interface.0.address}/\" /home/${var.ssh_user}/.ssh/config'"
  }

	provisioner "remote-exec" {
    inline = [
    	"sudo rm -rf /tmp/terraform*"
    ]
  }

}
