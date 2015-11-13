# aws-vpcizer

To use:
* Install Terraform (https://terraform.io/downloads.html)
* Set your AWS ENV Variables.
* Clone this repo
* checkout 'spinnaker' branch
* generate ssh key
* Look at terraform.tfvars and change anything you think might need changing (region, vpc_name, vpc_cidr)
  * set ssh_private_key_location with the filesystem location of the ssh private key you created.
  * set ssh_public_key to be the value of the public key.
  * set adm_bastion_incoming_cidrs and infra_jenkins_incoming_cidrs to a comma separated list of CIDRS that need to access those services.
  * for now, do not change ssh_key_name
* run the script:
```
./create_spinnaker_vpc.sh -a apply -c aws
```
