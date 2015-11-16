

variable "region" {}
variable "vpc_cidr" {}
variable "vpc_name" {}
variable "ssh_public_key" {}
variable "ssh_key_name" {}
variable "ssh_private_key_location" {}
variable "ssh_user" {}
variable "aptly_repo_key" {}
variable "ppa_repo_key" {}
variable "jenkins_admin_username" {}
variable "jenkins_admin_password" {}
variable "packer_url" {}
variable "created_by" {}
variable "docker_repo_key" {}

variable "jenkins_instance_type" {}
variable "bastion_instance_type" {}
variable "spinnaker_instance_type" {}

variable "internal_dns_zone" {}

variable "adm_bastion_incoming_cidrs" {}
variable "infra_jenkins_incoming_cidrs" {}


variable "trusty_amis" {
  default = {}
}

module "tf_kenzan" {
  source = "github.com/jpancoast-kenzan/tf_kenzan_spinnaker"
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
variable "count_public_subnet_block" {
  default = 9
}

#vpcName.internal.<availabilityZone>)
variable "public_subnet_block" {
 default = {
  "0" = "0.0/24;eelb_public;{\"purpose\":\"eelb\",\"target\":\"elb\"}"
  "1" = "1.0/24;eelb_public;{\"purpose\":\"eelb\",\"target\":\"elb\"}"
  "2" = "2.0/24;eelb_public;{\"purpose\":\"eelb\",\"target\":\"elb\"}"

  "3" = "3.0/26;admin_public;{\"purpose\":\"admin\",\"target\":\"ec2\"}"
  "4" = "3.64/26;admin_public;{\"purpose\":\"admin\",\"target\":\"ec2\"}"
  "5" = "3.128/26;admin_public;{\"purpose\":\"admin\",\"target\":\"ec2\"}"

  "6" = "8.0/22;ec2_public;{\"purpose\":\"ec2\",\"target\":\"ec2\"}"
  "7" = "12.0/22;ec2_public;{\"purpose\":\"ec2\",\"target\":\"ec2\"}"
  "8" = "16.0/22;ec2_public;{\"purpose\":\"ec2\",\"target\":\"ec2\"}"
  }
} 

variable "spinnaker_ami" {
  default = {
    "us-west-1" = "ami-76583616"
    "eu-west-1" = "ami-5f954f2c"
    "eu-central-1" = "ami-a36476cf"
    "ap-southeast-1" = "ami-ab589ec8"
    "ap-southeast-2" = "ami-f6045d95"
    "ap-northeast-1" = "ami-a2b797cc"
    "sa-east-1" = "ami-8173c9ed"
    "us-west-2" = "ami-04e1f065"
    "us-east-1" = "ami-e5b9c38f"
  }
}

# 
# loop count for setting up muliple private subnets
#   This should match the number of entries in the 'private_subnet_block' map
#   because there is no way to get a length on a map in terraform as of this
#   writing.
#
variable "count_private_subnet_block" {
  default = 3
}

variable "private_subnet_block" {
  default = {
    "0" = "4.0/24;ielb_private;{\"purpose\":\"ielb\",\"target\":\"elb\"}"
    "1" = "5.0/24;ielb_private;{\"purpose\":\"ielb\",\"target\":\"elb\"}"
    "2" = "6.0/24;ielb_private;{\"purpose\":\"ielb\",\"target\":\"elb\"}"
  }
} 

