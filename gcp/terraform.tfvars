
credentials_file = "~/.gce/jpancoast-gmail-kenzan-spinnaker.json"
project = "spinnaker-1127"
region = "us-central1"
zone = "a"

network_cidr = "10.0.0.0/16"

ssh_private_key_location = "~/.ssh/google_compute_engine"

bastion_machine_type = "f1-micro"
spinnaker_machine_type = "n1-highmem-8"

created_by = "Kenzan Spinnaker Terraform"

kenzan_statepath = "../gcp" #Hardcoding this for now.

ubuntu_image = "ubuntu-1404-trusty-v20151113"
spinnaker_image = "spinnaker-codelab"

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
#	adm_bastion_incoming_cidrs is inbound to port 22
#
#		Example:
#	adm_bastion_incoming_cidrs = "39.9.9.9/32,8.20.4.0/24"
#
#
#	NOTE: The IP of the machine that Terraform is running on will be automatically determined and does 
#		not need to be entered here.
#
#adm_bastion_incoming_cidrs = ""

#
#	Stuff that you probably won't have to update that often
#
ppa_repo_key = "C2518248EEA14886"

