variable "region" {}
variable "project" {}
variable "credentials_file" {}
variable "network_cidr" {}

variable "bastion_machine_type" {}
#variable "jenkins_machine_type" {}
variable "zone" {}
variable "ubuntu_image" {}
variable "spinnaker_image" {}
variable "spinnaker_machine_type" {}

variable "ssh_user" {}
variable "ssh_private_key_location" {}


#variable "jenkins_admin_username" {}
#variable "jenkins_admin_password" {}

variable "ppa_repo_key" {}
variable "packer_url" {}

variable "kenzan_statepath" {}