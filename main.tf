# main terraform
# provider

module "vpc" {
	source = "./vpc"
}

#module "securitygroups" {
#    source = "./securitygroups"
#}

module "iam" {
    source = "./iam"
}

module "keypair" {
    source = "./keypair"
}
