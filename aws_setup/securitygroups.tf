
 /* security group for eelb  */
resource "aws_security_group" "eelb" {
  vpc_id = "${aws_vpc.main.id}"
  name="eelb"
  description="security group for eelb"
  tags {
    Name="eelb_${var.vpc_tag_name}"
    created_on="2015-08-03"
    created_by="Kenzanmedia terraform"
    application="none"
    allocated="false"
    allocated_on="none"
    owner="none"
  }
  ingress {
    from_port=80
    to_port=80
    protocol="tcp"
    cidr_blocks=["${var.base_ip}${var.subnets.eelb}"]
  }
  ingress {
    from_port=443
    to_port=443
    protocol="tcp"
    cidr_blocks=["${var.base_ip}${var.subnets.eelb}"]
  }
  egress {
     from_port="0"
     to_port="0"
     protocol="-1"
     cidr_blocks=["0.0.0.0/0"]
  }
}

 /* security group for elb  */
resource "aws_security_group" "elb" {
  vpc_id = "${aws_vpc.main.id}"
  name="elb"
  description="security group for elb"
  tags {
    Name="elb_${var.vpc_tag_name}"
    created_on="2015-08-03"
    created_by="Kenzanmedia terraform"
    application="none"
    allocated="false"
    allocated_on="none"
    owner="none"
  }
  ingress {
    from_port=80
    to_port=80
    protocol="tcp"
    cidr_blocks=["${var.base_ip}${var.subnets.elb}"]
  }
  ingress {
    from_port=443
    to_port=443
    protocol="tcp"
    cidr_blocks=["${var.base_ip}${var.subnets.elb}"]
  }
  egress {
     from_port="0"
     to_port="0"
     protocol="-1"
     cidr_blocks=["0.0.0.0/0"]
  }
}

 /* security group for infra_asgard  */
resource "aws_security_group" "infra_asgard" {
  vpc_id = "${aws_vpc.main.id}"
  name="infra_asgard"
  description="security group for infra_asgard"
  tags {
    Name="infra_asgard_${var.vpc_tag_name}"
    created_on="2015-08-03"
    created_by="Kenzanmedia terraform"
    application="none"
    allocated="false"
    allocated_on="none"
    owner="none"
  }
  ingress {
    from_port=80
    to_port=80
    protocol="tcp"
    cidr_blocks=["${var.base_ip}${var.subnets.infra}"]
  }
  ingress {
    from_port=443
    to_port=443
    protocol="tcp"
    cidr_blocks=["${var.base_ip}${var.subnets.infra}"]
  }
  ingress {
    from_port=8080
    to_port=8080
    protocol="tcp"
    cidr_blocks=["${var.base_ip}${var.subnets.infra}"]
  }
  egress {
     from_port="0"
     to_port="0"
     protocol="-1"
     cidr_blocks=["0.0.0.0/0"]
  }
}

 /* security group for infra_eureka  */
resource "aws_security_group" "infra_eureka" {
  vpc_id = "${aws_vpc.main.id}"
  name="infra_eureka"
  description="security group for infra_eureka"
  tags {
    Name="infra_eureka_${var.vpc_tag_name}"
    created_on="2015-08-03"
    created_by="Kenzanmedia terraform"
    application="none"
    allocated="false"
    allocated_on="none"
    owner="none"
  }
  ingress {
    from_port=80
    to_port=80
    protocol="tcp"
    cidr_blocks=["${var.base_ip}${var.subnets.infra}"]
  }
  ingress {
    from_port=443
    to_port=443
    protocol="tcp"
    cidr_blocks=["${var.base_ip}${var.subnets.infra}"]
  }
  ingress {
    from_port=7001
    to_port=7001
    protocol="tcp"
    cidr_blocks=["${var.base_ip}${var.subnets.infra}"]
  }
  egress {
     from_port="0"
     to_port="0"
     protocol="-1"
     cidr_blocks=["0.0.0.0/0"]
  }
}

 /* security group for infra_bastion  */
resource "aws_security_group" "infra_bastion" {
  vpc_id = "${aws_vpc.main.id}"
  name="infra_bastion"
  description="security group for infra_bastion"
  tags {
    Name="infra_bastion_${var.vpc_tag_name}"
    created_on="2015-08-03"
    created_by="Kenzanmedia terraform"
    application="none"
    allocated="false"
    allocated_on="none"
    owner="none"
  }
  ingress {
    from_port=22
    to_port=22
    protocol="tcp"
    cidr_blocks=["${var.base_ip}${var.subnets.admin}"]
  }
  egress {
     from_port="0"
     to_port="0"
     protocol="-1"
     cidr_blocks=["0.0.0.0/0"]
  }
}

 /* security group for developer_access  */
resource "aws_security_group" "developer_access" {
  vpc_id = "${aws_vpc.main.id}"
  name="developer_access"
  description="security group for developer_access"
  tags {
    Name="developer_access_${var.vpc_tag_name}"
    created_on="2015-08-03"
    created_by="Kenzanmedia terraform"
    application="none"
    allocated="false"
    allocated_on="none"
    owner="none"
  }
  ingress {
    from_port=0
    to_port=0
    protocol="-1"
    cidr_blocks=["${var.base_ip}0.0/16"]
  }
  egress {
     from_port="0"
     to_port="0"
     protocol="-1"
     cidr_blocks=["0.0.0.0/0"]
  }
}
