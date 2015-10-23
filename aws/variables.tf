

variable "region" {}
variable "vpc_cidr" {}
variable "vpc_name" {}
variable "ssh_public_key" {}
variable "ssh_key_name" {}
variable "run_date" {}
variable "ssh_private_key_location" {}
variable "ssh_user" {}

variable "trusty_amis" {
  default = {}
}

variable "azs_per_region" {
  default = 3
}




# 
# loop count for setting up muliple public subnets
#   This should match the number of entries in the 'public_subnet_block' map
#   because there is no way to get a length on a map in terraform as of this
#   writing.
#
variable "count_public_subnet_block" {
  default = 9
}

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
    "0" = "4.0/24;ielb_private;{\"purpose\":\"ielb\",\"target\":\"ec2\"}"
    "1" = "5.0/24;ielb_private;{\"purpose\":\"ielb\",\"target\":\"ec2\"}"
    "2" = "6.0/24;ielb_private;{\"purpose\":\"ielb\",\"target\":\"ec2\"}"
  }
} 


variable "azs" {
  default = {
    "us-west-2" = "a:b:c"
    "us-east-1" = "b:c:d"
    "us-west-1" = "a:b:c"
  }
}
