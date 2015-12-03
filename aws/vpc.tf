provider "aws" {
    region = "${var.region}"
}

resource "aws_vpc" "main" {
    cidr_block = "${var.vpc_cidr}"
    instance_tenancy = "default"
    enable_dns_hostnames = "true"
    tags {
        Name = "${var.vpc_name}"
    }
}

/* IELB Private subnets */
resource "aws_subnet" "ielb_private_subnets" {

  count = "${length(split(":", lookup(var.aws_azs, var.region)))}"
  
  cidr_block           = "${element(split (".", var.vpc_cidr), 0)}.${element(split (".", var.vpc_cidr), 1)}.${element(split (";", "${lookup(var.ielb_private_subnet_block, count.index)}"), 0)}"
  availability_zone    = "${var.region}${element(split (":", "${lookup(var.aws_azs, var.region)}"), count.index%"${lookup(var.aws_az_counts, var.region)}")}"
    tags {
      Name               = "${var.vpc_name}.${element(split (";", "${lookup(var.ielb_private_subnet_block, count.index)}"), 1)}.${var.region}"
    }
  vpc_id = "${aws_vpc.main.id}"
}

#vpcName.internal.<availabilityZone>)
/* EELB Public subnets */
resource "aws_subnet" "eelb_public_subnet" {

  count = "${length(split(":", lookup(var.aws_azs, var.region)))}"

  cidr_block           = "${element(split (".", var.vpc_cidr), 0)}.${element(split (".", var.vpc_cidr), 1)}.${element(split (";", "${lookup(var.eelb_public_subnet_block, count.index)}"), 0)}"
  availability_zone   = "${var.region}${element(split (":", "${lookup(var.aws_azs, var.region)}"), count.index%"${lookup(var.aws_az_counts, var.region)}")}"
  map_public_ip_on_launch = true
  depends_on = ["aws_internet_gateway.gw"]
    tags {
      Name               = "${var.vpc_name}.${element(split (";", "${lookup(var.eelb_public_subnet_block, count.index)}"), 1)}.${var.region}"
    }
  vpc_id = "${aws_vpc.main.id}"
}

/* ADMIN Public subnets */
resource "aws_subnet" "admin_public_subnet" {

  count = "${length(split(":", lookup(var.aws_azs, var.region)))}"

  cidr_block           = "${element(split (".", var.vpc_cidr), 0)}.${element(split (".", var.vpc_cidr), 1)}.${element(split (";", "${lookup(var.admin_public_subnet_block, count.index)}"), 0)}"
  availability_zone   = "${var.region}${element(split (":", "${lookup(var.aws_azs, var.region)}"), count.index%"${lookup(var.aws_az_counts, var.region)}")}"
  map_public_ip_on_launch = true
  depends_on = ["aws_internet_gateway.gw"]
    tags {
      Name               = "${var.vpc_name}.${element(split (";", "${lookup(var.admin_public_subnet_block, count.index)}"), 1)}.${var.region}"
    }
  vpc_id = "${aws_vpc.main.id}"
}

/* EC2 Public subnets */
resource "aws_subnet" "ec2_public_subnet" {

  count = "${length(split(":", lookup(var.aws_azs, var.region)))}"

  cidr_block           = "${element(split (".", var.vpc_cidr), 0)}.${element(split (".", var.vpc_cidr), 1)}.${element(split (";", "${lookup(var.ec2_public_subnet_block, count.index)}"), 0)}"
  availability_zone   = "${var.region}${element(split (":", "${lookup(var.aws_azs, var.region)}"), count.index%"${lookup(var.aws_az_counts, var.region)}")}"
  map_public_ip_on_launch = true
  depends_on = ["aws_internet_gateway.gw"]
    tags {
      Name               = "${var.vpc_name}.${element(split (";", "${lookup(var.ec2_public_subnet_block, count.index)}"), 1)}.${var.region}"
    }
  vpc_id = "${aws_vpc.main.id}"
}

/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "gw" {
  tags {
    Name = "GW_${aws_vpc.main.id}"
  }
  vpc_id = "${aws_vpc.main.id}"
}


/* Routing table for public subnet */
resource "aws_route_table" "gw_rt" {
    vpc_id = "${aws_vpc.main.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gw.id}"
    }
    tags {
        Name = "main"
    }
}

/* Associate the routing table to the EELB public subnets */
resource "aws_route_table_association" "eelb_public" {
    count = "${length(split(":", lookup(var.aws_azs, var.region)))}"
    subnet_id = "${element(aws_subnet.eelb_public_subnet.*.id, count.index)}"
    route_table_id = "${aws_route_table.gw_rt.id}"
    depends_on = ["aws_vpc.main", "aws_internet_gateway.gw"]
}

/* Associate the routing table to the ADMIN public subnets */
resource "aws_route_table_association" "admin_public" {
    count = "${length(split(":", lookup(var.aws_azs, var.region)))}"
    subnet_id = "${element(aws_subnet.admin_public_subnet.*.id, count.index)}"
    route_table_id = "${aws_route_table.gw_rt.id}"
    depends_on = ["aws_vpc.main", "aws_internet_gateway.gw"]
}

/* Associate the routing table to the EC2 public subnets */
resource "aws_route_table_association" "ec2_public" {
    count = "${length(split(":", lookup(var.aws_azs, var.region)))}"
    subnet_id = "${element(aws_subnet.ec2_public_subnet.*.id, count.index)}"
    route_table_id = "${aws_route_table.gw_rt.id}"
    depends_on = ["aws_vpc.main", "aws_internet_gateway.gw"]
}


