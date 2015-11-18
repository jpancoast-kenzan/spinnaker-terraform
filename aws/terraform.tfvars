
#
#	Variables to be updated by each user
#
region = "us-west-2"
vpc_cidr = "192.168.0.0/16"
vpc_name = "vpc_DIFFNAME"
ssh_key_name = "my-aws-account-keypair"

ssh_private_key_location = "/Users/jpancoast/.ssh/id_rsa_spinnaker_terraform"
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDkWmtpATmnVRgrtylVNdyPsCZJWC4i/dJLeqxm0rv9pJDrFNSLzHKrjzBaxrTUW69VzymgSGD6owAmtQEYffx7n8nyacp91f6s9jhUgqtXJAljQ2KVD424gNMmJeP4yHtzavUbucI7bNbhHH4pJSuVCOOsX7ULHVuaE+VPSOXBBV6XC6x4isfyn1k7SnYcWWJ36HRSpp2hoXxR1QC+31vyQJjW6F5UAILkw5CadVHghi+tp/aVoTrmG3bQNvsNKn9glFHZHo0ATwuJS3LY1LdylX7FiD6wcGt3QLqwmGpR03sEO4n+WZCxRMlXWLZVWS+SpKJTidqqoHbbpRsl8wDh jpancoast@jpancoast-kenzan.local"

jenkins_admin_username = "admin"
jenkins_admin_password = "admin123"

packer_url = "https://dl.bintray.com/mitchellh/packer/packer_0.8.6_linux_amd64.zip"
jenkins_instance_type = "t2.small"
bastion_instance_type = "t2.small"
spinnaker_instance_type = "m4.2xlarge"

created_by = "Kenzan Spinnaker Terraform"

internal_dns_zone = "kenzan.int"



spinnaker_ami.us-east-1 = "ami-837a3fe9"
spinnaker_ami.us-west-1 = "ami-d811cbab"
spinnaker_ami.us-west-2 = "ami-094a5a68"

spinnaker_ami.eu-west-1 = "ami-839cf2e3"
spinnaker_ami.eu-central-1 = "ami-643e2c08"
spinnaker_ami.ap-southeast-1 = "ami-858d4ce"

spinnaker_ami.ap-southeast-2 = "ami-5b5f0638"
spinnaker_ami.ap-northeast-1 = "ami-fb012295"
spinnaker_ami.sa-east-1 = "ami-b243f9de"

#
#us-east-1      | Spinnaker-Ubuntu-14.04-9 | 14.04 LTS      | HVM           | ami-837a3fe9 |
#+| us-west-1      | Spinnaker-Ubuntu-14.04-9 | 14.04 LTS      | HVM           | ami-d811cbab |
#+| us-west-2      | Spinnaker-Ubuntu-14.04-9 | 14.04 LTS      | HVM           | ami-094a5a68 |
#
#+| eu-west-1      | Spinnaker-Ubuntu-14.04-9 | 14.04 LTS      | HVM           | ami-839cf2e3 |
#+| eu-central-1   | Spinnaker-Ubuntu-14.04-9 | 14.04 LTS      | HVM           | ami-643e2c08 |
#+| ap-southeast-1 | Spinnaker-Ubuntu-14.04-9 | 14.04 LTS      | HVM           | ami-858d4ce |
#
#+| ap-southeast-2 | Spinnaker-Ubuntu-14.04-9 | 14.04 LTS      | HVM           | ami-5b5f0638 |
#+| ap-northeast-1 | Spinnaker-Ubuntu-14.04-9 | 14.04 LTS      | HVM           | ami-fb012295 |
#+| sa-east-1      | Spinnaker-Ubuntu-14.04-9 | 14.04 LTS      | HVM           | ami-b243f9de


#
#	For the following '..._incoming_cidrs', you can use a comma separated list of incoming CIDRS
#

#
#	adm_bastion is inbound to port 22
#
adm_bastion_incoming_cidrs = "38.75.226.18/32,67.190.184.208/32"

#
#	infra_jenkins are inbound to port 80
#
infra_jenkins_incoming_cidrs = "38.75.226.18/32,67.190.184.208/32"


#
#	Stuff that you probably won't have to update that often
#
#aptly_repo_key = "E083A3782A194991"
ppa_repo_key = "C2518248EEA14886"
#docker_repo_key = "58118E89F3A912897C070ADBF76221572C52609D"
ssh_user = "ubuntu"
