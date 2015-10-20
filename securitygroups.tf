
/* security group for eelb  */
resource "aws_security_group" "eelb" {
  vpc_id = "${aws_vpc.main.id}"
  name="EELB"
  description="security group for eelb"
  tags {
    Name="EELB"
    created_on="2015-08-03 this date is actually quite invalid"
    created_by="Kenzan terraform"
    application="none"
    allocated="false"
    allocated_on="none"
    owner="none"
  }
  ingress {
    from_port=80
    to_port=80
    protocol="tcp"
    cidr_blocks=["0.0.0.0/0"]
  }
  ingress {
    from_port=443
    to_port=443
    protocol="tcp"
    cidr_blocks=["0.0.0.0/0"]
  }
  egress {
     from_port="0"
     to_port="0"
     protocol="-1"
     cidr_blocks=["${var.vpc_cidr}"]
  }
}

/* security group for ielb  */
resource "aws_security_group" "ielb" {
  vpc_id = "${aws_vpc.main.id}"
  name="IELB"
  description="security group for ielb"
  tags {
    Name="IELB"
    created_on="2015-08-03 this date is actually quite invalid"
    created_by="Kenzan terraform"
    application="none"
    allocated="false"
    allocated_on="none"
    owner="none"
  }
  ingress {
    from_port=80
    to_port=80
    protocol="tcp"
    cidr_blocks=["${var.vpc_cidr}"]
  }
  ingress {
    from_port=443
    to_port=443
    protocol="tcp"
    cidr_blocks=["${var.vpc_cidr}"]
  }
  egress {
     from_port="0"
     to_port="0"
     protocol="-1"
     cidr_blocks=["${var.vpc_cidr}"]
  }
}
#${lookup(var.public_subnet_block, count.index)}
#"${element(split (";", "${lookup(var.public_subnet_block, count.index)}"), 2)}"
/* VPC sg */
resource "aws_security_group" "vpc_sg" {
  vpc_id = "${aws_vpc.main.id}"
  name="VPC_${element(split ("-", "${aws_vpc.main.id}"), 1)}"
  description="VPC Default Security group for ${aws_vpc.main.id}"
  tags {
    Name="VPC_${element(split ("-", "${aws_vpc.main.id}"), 1)}"
    created_on="2015-08-03 this date is actually quite invalid"
    created_by="Kenzan terraform"
    application="none"
    allocated="false"
    allocated_on="none"
    owner="none"
#    temp = "${replace(aws_vpc.main.id, 'vpc-', 'b')}"
#    temp = "${element(split ("-", "${aws_vpc.main.id}"), 1)}"
  }
  egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks=["${var.vpc_cidr}"]
  }
}


 /* security group for elb  */
#resource "aws_security_group" "elb" {
#  vpc_id = "${aws_vpc.main.id}"
#  name="elb"
#  description="security group for elb"
#  tags {
#    Name="elb_${var.vpc_tag_name}"
#    created_on="2015-08-03"
#    created_by="Kenzanmedia terraform"
#    application="none"
#    allocated="false"
#    allocated_on="none"
#    owner="none"
#  }
#  ingress {
#    from_port=80
#    to_port=80
#    protocol="tcp"
#    cidr_blocks=["${var.base_ip}${var.subnets.elb}"]
#  }
#  ingress {
#    from_port=443
#    to_port=443
#    protocol="tcp"
#    cidr_blocks=["${var.base_ip}${var.subnets.elb}"]
#  }
#  egress {
#     from_port="0"
#     to_port="0"
#     protocol="-1"
#     cidr_blocks=["0.0.0.0/0"]
#  }
#}

 /* security group for infra_asgard  */
#resource "aws_security_group" "infra_asgard" {
#  vpc_id = "${aws_vpc.main.id}"
#  name="infra_asgard"
#  description="security group for infra_asgard"
#  tags {
#    Name="infra_asgard_${var.vpc_tag_name}"
#    created_on="2015-08-03"
#    created_by="Kenzanmedia terraform"
#    application="none"
#    allocated="false"
#    allocated_on="none"
#    owner="none"
#  }
#  ingress {
#    from_port=80
#    to_port=80
#    protocol="tcp"
#    cidr_blocks=["${var.base_ip}${var.subnets.infra}"]
#  }
#  ingress {
#    from_port=443
#    to_port=443
#    protocol="tcp"
#    cidr_blocks=["${var.base_ip}${var.subnets.infra}"]
#  }
#  ingress {
#    from_port=8080
#    to_port=8080
#    protocol="tcp"
#    cidr_blocks=["${var.base_ip}${var.subnets.infra}"]
#  }
#  egress {
#     from_port="0"
#     to_port="0"
#     protocol="-1"
#     cidr_blocks=["0.0.0.0/0"]
#  }
#}

 /* security group for infra_eureka  */
#resource "aws_security_group" "infra_eureka" {
#  vpc_id = "${aws_vpc.main.id}"
#  name="infra_eureka"
#  description="security group for infra_eureka"
#  tags {
#    Name="infra_eureka_${var.vpc_tag_name}"
#    created_on="2015-08-03"
#    created_by="Kenzanmedia terraform"
#    application="none"
#    allocated="false"
#    allocated_on="none"
#    owner="none"
#  }
#  ingress {
#    from_port=80
#    to_port=80
#    protocol="tcp"
#    cidr_blocks=["${var.base_ip}${var.subnets.infra}"]
#  }
#  ingress {
#    from_port=443
#    to_port=443
#    protocol="tcp"
#    cidr_blocks=["${var.base_ip}${var.subnets.infra}"]
#  }
#  ingress {
#    from_port=7001
#    to_port=7001
#    protocol="tcp"
#    cidr_blocks=["${var.base_ip}${var.subnets.infra}"]
#  }
#  egress {
#     from_port="0"
#     to_port="0"
#     protocol="-1"
#     cidr_blocks=["0.0.0.0/0"]
#  }
#}

 /* security group for infra_bastion  */
#resource "aws_security_group" "infra_bastion" {
#  vpc_id = "${aws_vpc.main.id}"
#  name="infra_bastion"
#  description="security group for infra_bastion"
#  tags {
#    Name="infra_bastion_${var.vpc_tag_name}"
#    created_on="2015-08-03"
#    created_by="Kenzanmedia terraform"
#    application="none"
#    allocated="false"
#    allocated_on="none"
#    owner="none"
#  }
#  ingress {
#    from_port=22
#    to_port=22
#    protocol="tcp"
#    cidr_blocks=["${var.base_ip}${var.subnets.admin}"]
#  }
#  egress {
#     from_port="0"
#     to_port="0"
#     protocol="-1"
#     cidr_blocks=["0.0.0.0/0"]
#  }
#}

 /* security group for developer_access  */
#resource "aws_security_group" "developer_access" {
#  vpc_id = "${aws_vpc.main.id}"
#  name="developer_access"
#  description="security group for developer_access"
#  tags {
#    Name="developer_access_${var.vpc_tag_name}"
#    created_on="2015-08-03"
#    created_by="Kenzanmedia terraform"
#    application="none"
#    allocated="false"
#    allocated_on="none"
#    owner="none"
#  }
#  ingress {
#    from_port=0
#    to_port=0
#    protocol="-1"
#    cidr_blocks=["${var.base_ip}0.0/16"]
#  }
#  egress {
#     from_port="0"
#     to_port="0"
#     protocol="-1"
#     cidr_blocks=["0.0.0.0/0"]
#  }
#}
