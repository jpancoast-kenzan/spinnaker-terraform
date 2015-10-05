provider "aws" {
    region = "${var.region}"
}

resource "aws_vpc" "main" {
    cidr_block = "${var.top_cidr}"
    instance_tenancy = "default"
    enable_dns_hostnames = "true"
    tags {
        Name = "${var.tag_name}"
    }
}

/* Private subnet */
resource "aws_subnet" "private_subnets" {

  count = "${var.count_private_subnet_block}"
  
  cidr_block           = "${var.base_ip}${element(split (";", "${lookup(var.private_subnet_block, count.index)}"), 0)}"
  availability_zone    = "${element(split (";", "${lookup(var.private_subnet_block, count.index)}"), 1)}"
    tags {
    Name               = "${element(split (";", "${lookup(var.private_subnet_block, count.index)}"), 2)}"
    immutable_metadata = "${element(split (";", "${lookup(var.private_subnet_block, count.index)}"), 3)}"
    }
  vpc_id = "${aws_vpc.main.id}"
}


/* Public subnet */
resource "aws_subnet" "public_subnet" {

count = "${var.count_public_subnet_block}"

  cidr_block          = "${var.base_ip}${element(split (";", "${lookup(var.public_subnet_block, count.index)}"), 0)}"
  availability_zone   = "${element(split (";", "${lookup(var.public_subnet_block, count.index)}"), 1)}"
  map_public_ip_on_launch = true
  depends_on = ["aws_internet_gateway.gw"]
    tags {
    Name               = "${element(split (";", "${lookup(var.public_subnet_block, count.index)}"), 2)}"
    immutable_metadata = "${element(split (";", "${lookup(var.public_subnet_block, count.index)}"), 3)}"
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
        cidr_block = "0.0.0.0/16"
        gateway_id = "${aws_internet_gateway.gw.id}"
    }
    tags {
        Name = "main"
    }
}

/* Associate the routing table to public subnet */
resource "aws_route_table_association" "public" {
    subnet_id = "${element(aws_subnet.public_subnet.*.id, count.index)}"
    route_table_id = "${aws_route_table.gw_rt.id}"
    count = "${var.count_public_subnet_block}"
    depends_on = ["aws_vpc.main", "aws_internet_gateway.gw"]
}



