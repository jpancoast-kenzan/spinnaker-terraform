
#
#	Variables to be updated by each user
#
region = "us-west-2"
vpc_cidr = "192.168.0.0/16"
vpc_name = "vpc_DIFFNAME"
ssh_key_name = "my-aws-account-keypair"

ssh_private_key_location = "~/.ssh/id_rsa_spinnaker_terraform"
ssh_public_key_location = "~/.ssh/id_rsa_spinnaker_terraform.pub"

packer_url = "https://dl.bintray.com/mitchellh/packer/packer_0.8.6_linux_amd64.zip"
jenkins_instance_type = "t2.small"
bastion_instance_type = "t2.micro"
spinnaker_instance_type = "m4.2xlarge"

created_by = "Kenzan Spinnaker Terraform"

internal_dns_zone = "kenzanlabs.int"


#
#	Jenkins user
#
jenkins_admin_username = "admin"

#
#	This NEEDS TO BE SET. Either in this file or you will be prompted for them.
#		If you set them in here, uncomment them.
#
#jenkins_admin_password = "DO NOT LEAVE EMPTY IF YOU SET IT IN HERE"

#
#	IAM roles
#
jenkins_iam_role_name = "jenkins_iam_role"
base_iam_role_name = "base_iam_role_testing"
spinnaker_iam_role_name = "spinnaker_iam_role"
properties_and_logging_iam_role_name = "properties_and_logging_iam_role"


#
#	infra_jenkins_incoming_cidrs is inbound to the jenkins host on port 80
#
#		Example:
#	infra_jenkins_incoming_cidrs = "39.9.9.9/32,8.20.4.0/24"
#
#	NOTE: The IP of the machine that Terraform is running on will be automatically determined and does 
#		not need to be entered here.
#
infra_jenkins_incoming_cidrs = ""

#
#	adm_bastion_incoming_cidrs is inbound to port 22
#
#		Example:
#	adm_bastion_incoming_cidrs = "39.9.9.9/32,8.20.4.0/24"
#
#
#	NOTE: The IP of the machine that Terraform is running on will be automatically determined and does 
#		not need to be entered here.
#
adm_bastion_incoming_cidrs = ""


#
#	Stuff that you probably won't have to update that often
#
ppa_repo_key = "C2518248EEA14886"
ssh_user = "ubuntu"

#
#	What kind of ubuntu AMI's do you want.
#		These are the recommended values. CHANGE AT YOUR OWN RISK.
#
ubuntu_distribution = "trusty"
ubuntu_virttype = "hvm"
ubuntu_architecture = "amd64"
ubuntu_storagetype = "ebs-ssd"