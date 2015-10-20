

variable "region" {
  default = "us-west-2"
}
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

# vpc tag name
variable "vpc_tag_name" {
  default = "vpc_A"
}

variable "base_ip" {
  default="10.10."
}



# loop count for setting up muliple public subnets
variable "count_public_subnet_block" {
  default = 9
}

# loop count for setting up muliple private subnets
variable "count_private_subnet_block" {
  default = 3
}

# Sub netting defaults
#variable "subnets" {
#  default = {
#    "eelb"="192.0/22"
#    "elb"="195.0/22"
#    "infra"="198.0/22"
#    "admin"="201.0/22"
#  }
#}


variable "public_subnet_block" {
 default = {
  "0" = "0.0/24;a;eelb_public_vpc_A;{\"purpose\":\"eelb\",\"target\":\"elb\"}"
  "1" = "1.0/24;b;eelb_public_vpc_A;{\"purpose\":\"eelb\",\"target\":\"elb\"}"
  "2" = "2.0/24;c;eelb_public_vpc_A;{\"purpose\":\"eelb\",\"target\":\"elb\"}"

  "3" = "3.0/26;a;admin_public_vpc_A;{\"purpose\":\"admin\",\"target\":\"ec2\"}"
  "4" = "3.64/26;b;admin_public_vpc_A;{\"purpose\":\"admin\",\"target\":\"ec2\"}"
  "5" = "3.128/26;c;admin_public_vpc_A;{\"purpose\":\"admin\",\"target\":\"ec2\"}"

  "6" = "8.0/22;a;ec2_public_vpc_A;{\"purpose\":\"ec2\",\"target\":\"ec2\"}"
  "7" = "12.0/22;b;ec2_public_vpc_A;{\"purpose\":\"ec2\",\"target\":\"ec2\"}"
  "8" = "16.0/22;c;ec2_public_vpc_A;{\"purpose\":\"ec2\",\"target\":\"ec2\"}"
  }
} 

variable "private_subnet_block" {
 default = {

  "0" = "4.0/24;a;ielb_private_vpc_A;{\"purpose\":\"ielb\",\"target\":\"ec2\"}"
  "1" = "5.0/24;b;ielb_private_vpc_A;{\"purpose\":\"ielb\",\"target\":\"ec2\"}"
  "2" = "6.0/24;c;ielb_private_vpc_A;{\"purpose\":\"ielb\",\"target\":\"ec2\"}"

  }
} 


# availability Zones
variable "az" {
    default = {
        "1b" = "us-west-2a"
        "1c" = "us-west-2b"
        "1d" = "us-west-2c"
    }
}







