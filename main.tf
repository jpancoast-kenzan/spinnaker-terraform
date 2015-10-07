# main terraform
# provider

module "vpc" {
	source = "modules/vpc"
}

#module "securitygroups" {
#    source = "./securitygroups"
#}

module "iam" {
    source = "modules/iam"
}

module "keypair" {
    source = "modules/keypair"
}
