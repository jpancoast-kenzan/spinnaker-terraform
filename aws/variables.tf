

variable "region" {}
variable "vpc_cidr" {}
variable "vpc_name" {}
variable "ssh_key_name" {}
variable "ssh_private_key_location" {}
variable "ssh_public_key_location" {}
variable "ssh_user" {}
variable "ppa_repo_key" {}
variable "jenkins_admin_username" {}
variable "jenkins_admin_password" {}
variable "packer_url" {}
variable "created_by" {}

variable "jenkins_instance_type" {}
variable "bastion_instance_type" {}
variable "spinnaker_instance_type" {}

variable "internal_dns_zone" {}

variable "adm_bastion_incoming_cidrs" {}
variable "infra_jenkins_incoming_cidrs" {}

module "tf_aws_kenzan_spinnaker" {
  source = "github.com/kenzanlabs/tf_aws_kenzan_spinnaker"
  region = "${var.region}"
  distribution = "trusty"
  architecture = "amd64"
  virttype = "hvm"
  storagetype = "ebs-ssd"
}



# 
# loop count for setting up muliple public subnets
#   This should match the number of entries in the 'public_subnet_block' map
#   because there is no way to get a length on a map in terraform as of this
#   writing. At least no way that I can find.
#
#variable "count_public_subnet_block" {
#  default = 9
#}
#
#variable "public_subnet_block" {
# default = {
#  "0" = "0.0/24;eelb_public;{\"purpose\":\"eelb\",\"target\":\"elb\"}"
#  "1" = "1.0/24;eelb_public;{\"purpose\":\"eelb\",\"target\":\"elb\"}"
#  "2" = "2.0/24;eelb_public;{\"purpose\":\"eelb\",\"target\":\"elb\"}"
#
#  "3" = "3.0/26;admin_public;{\"purpose\":\"admin\",\"target\":\"ec2\"}"
#  "4" = "3.64/26;admin_public;{\"purpose\":\"admin\",\"target\":\"ec2\"}"
#  "5" = "3.128/26;admin_public;{\"purpose\":\"admin\",\"target\":\"ec2\"}"
#
#  "6" = "8.0/22;ec2_public;{\"purpose\":\"ec2\",\"target\":\"ec2\"}"
#  "7" = "12.0/22;ec2_public;{\"purpose\":\"ec2\",\"target\":\"ec2\"}"
#  "8" = "16.0/22;ec2_public;{\"purpose\":\"ec2\",\"target\":\"ec2\"}"
#  }
#} 

variable "eelb_public_subnet_block" {
  default = {
    "0" = "0.0/24;eelb_public;{\"purpose\":\"eelb\",\"target\":\"elb\"}"
    "1" = "1.0/24;eelb_public;{\"purpose\":\"eelb\",\"target\":\"elb\"}"
    "2" = "2.0/24;eelb_public;{\"purpose\":\"eelb\",\"target\":\"elb\"}"
  }
}

variable "admin_public_subnet_block" {
  default = {
    "0" = "3.0/26;admin_public;{\"purpose\":\"admin\",\"target\":\"ec2\"}"
    "1" = "3.64/26;admin_public;{\"purpose\":\"admin\",\"target\":\"ec2\"}"
    "2" = "3.128/26;admin_public;{\"purpose\":\"admin\",\"target\":\"ec2\"}"
  }
}

variable "ec2_public_subnet_block" {
  default = {
    "0" = "8.0/22;ec2_public;{\"purpose\":\"ec2\",\"target\":\"ec2\"}"
    "1" = "12.0/22;ec2_public;{\"purpose\":\"ec2\",\"target\":\"ec2\"}"
    "2" = "16.0/22;ec2_public;{\"purpose\":\"ec2\",\"target\":\"ec2\"}"
  }
}

# 
# loop count for setting up muliple private subnets
#   This should match the number of entries in the 'private_subnet_block' map
#   because there is no way to get a length on a map in terraform as of this
#   writing. At least no way that I can find.
#
#variable "count_private_subnet_block" {
#  default = 3
#}

variable "ielb_private_subnet_block" {
  default = {
    "0" = "4.0/24;ielb_private;{\"purpose\":\"ielb\",\"target\":\"elb\"}"
    "1" = "5.0/24;ielb_private;{\"purpose\":\"ielb\",\"target\":\"elb\"}"
    "2" = "6.0/24;ielb_private;{\"purpose\":\"ielb\",\"target\":\"elb\"}"
  }
} 

