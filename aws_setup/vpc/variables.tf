

variable "region" {
  default = "us-west-2"
}

# vpc tag name
variable "tag_name" {
  default = "vpc_A"
}

variable "base_ip" {
  default="10.10."
}

variable "top_cidr" {
  default = "10.10.0.0/16"
}

# loop count for setting up muliple public subnets
variable "count_public_subnet_block" {
  default = 3
}

# loop count for setting up muliple private subnets
variable "count_private_subnet_block" {
  default = 6
}


variable "public_subnet_block" {
 default = {
  "0" = "0.0/24;us-west-2a;eelb_public_vpc_A;{\"purpose\":\"eelb\",\"target\":\"elb\"}"
  "1" = "1.0/24;us-west-2b;eelb_public_vpc_A;{\"purpose\":\"eelb\",\"target\":\"elb\"}"
  "2" = "2.0/24;us-west-2c;eelb_public_vpc_A;{\"purpose\":\"eelb\",\"target\":\"elb\"}"
  }
} 

variable "private_subnet_block" {
 default = {

  "0" = "4.0/24;us-west-2a;zuul_private_vpc_A;{\"purpose\":\"zuul\",\"target\":\"ec2\"}"
  "1" = "5.0/24;us-west-2b;zuul_private_vpc_A;{\"purpose\":\"vpc_A_zuul\",\"target\":\"ec2\"}"
  "2" = "6.0/24;us-west-2c;zuul_private_vpc_A;{\"purpose\":\"vpc_A_zuul\",\"target\":\"ec2\"}"

  "3" = "8.0/26;us-west-2a;loginedge_private_vpc_A;{\"purpose\":\"vpc_A_loginedge\",\"target\":\"ec2\"}"
  "4" = "8.64/26;us-west-2b;loginedge_private_vpc_A;{\"purpose\":\"vpc_A_loginedge\",\"target\":\"ec2\"}"
  "5" = "8.128/26;us-west-2c;loginedge_private_vpc_A;{\"purpose\":\"vpc_A_loginedge\",\"target\":\"ec2\"}"

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







