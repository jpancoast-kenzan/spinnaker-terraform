

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
variable "local_ip" {}

variable "ubuntu_distribution" {}
variable "ubuntu_virttype" {}
variable "ubuntu_architecture" {}
variable "ubuntu_storagetype" {}

variable "jenkins_iam_role_name" {}
variable "base_iam_role_name" {}
variable "spinnaker_iam_role_name" {}
variable "properties_and_logging_iam_role_name" {}

variable "kenzan_statepath" {}

variable "jenkins_profile_name" {}
variable "spinnaker_profile_name" {}
variable "properties_and_logging_profile_name" {}
variable "spinnaker_username" {}

variable "eelb_public_subnet_block" {
  default = {
    "0" = "0.0/24;eelb_public;{\"purpose\":\"eelb\",\"target\":\"elb\"}"
    "1" = "1.0/24;eelb_public;{\"purpose\":\"eelb\",\"target\":\"elb\"}"
    "2" = "2.0/24;eelb_public;{\"purpose\":\"eelb\",\"target\":\"elb\"}"
    "3" = "3.0/24;eelb_public;{\"purpose\":\"eelb\",\"target\":\"elb\"}"
  }
}

variable "admin_public_subnet_block" {
  default = {
    "0" = "4.0/26;admin_public;{\"purpose\":\"admin\",\"target\":\"ec2\"}"
    "1" = "4.64/26;admin_public;{\"purpose\":\"admin\",\"target\":\"ec2\"}"
    "2" = "4.128/26;admin_public;{\"purpose\":\"admin\",\"target\":\"ec2\"}"
    "3" = "4.192/26;admin_public;{\"purpose\":\"admin\",\"target\":\"ec2\"}"
  }
}

variable "ec2_public_subnet_block" {
  default = {
    "0" = "12.0/22;ec2_public;{\"purpose\":\"ec2\",\"target\":\"ec2\"}"
    "1" = "16.0/22;ec2_public;{\"purpose\":\"ec2\",\"target\":\"ec2\"}"
    "2" = "20.0/22;ec2_public;{\"purpose\":\"ec2\",\"target\":\"ec2\"}"
    "3" = "24.0/22;ec2_public;{\"purpose\":\"ec2\",\"target\":\"ec2\"}"
  }
}

variable "ielb_private_subnet_block" {
  default = {
    "0" = "5.0/24;ielb_private;{\"purpose\":\"ielb\",\"target\":\"elb\"}"
    "1" = "6.0/24;ielb_private;{\"purpose\":\"ielb\",\"target\":\"elb\"}"
    "2" = "7.0/24;ielb_private;{\"purpose\":\"ielb\",\"target\":\"elb\"}"
    "3" = "8.0/24;ielb_private;{\"purpose\":\"ielb\",\"target\":\"elb\"}"
  }
} 

variable "aws_spinnaker_amis" {
  "default" = {
    "ap-northeast-1-hvm" = "ami-c17a7daf"
    "ap-southeast-1-hvm" = "ami-ef11df8c"
    "ap-southeast-2-hvm" = "ami-911e39f2"
    "eu-central-1-hvm" = "ami-a5ced5c9"
    "eu-west-1-hvm" = "ami-ade152de"
    "sa-east-1-hvm" = "ami-cd8f0ca1"
    "us-east-1-hvm" = "ami-c33207a9"
    "us-west-1-hvm" = "ami-5deb9d3d"
    "us-west-2-hvm" = "ami-6ce8080c"
  }
}