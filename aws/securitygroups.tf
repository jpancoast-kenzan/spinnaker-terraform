
/* ADM_BASTION */
resource "aws_security_group" "adm_bastion" {
  vpc_id = "${aws_vpc.main.id}"
  name="ADM_BASTION"
  description="Bastion Host SG"
  tags {
    Name="ADM_BASTION"
    created_on="2015-08-03 or whatever"
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
    cidr_blocks=["0.0.0.0/0"]
  }
}


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
  }
  egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks=["${var.vpc_cidr}"]
  }
}


/* MGMT SG */
resource "aws_security_group" "mgmt_sg" {
  vpc_id = "${aws_vpc.main.id}"
  name="MGMT_${element(split ("-", "${aws_vpc.main.id}"), 1)}"
  description="MGMT Security group for ${aws_vpc.main.id}"
  tags {
    Name="MGMT_${element(split ("-", "${aws_vpc.main.id}"), 1)}"
    created_on="2015-08-03 this date is actually quite invalid"
    created_by="Kenzan terraform"
    application="none"
    allocated="false"
    allocated_on="none"
    owner="none"
  }
  ingress {
    from_port="22"
    to_port="22"
    protocol="tcp"
    security_groups=["${aws_security_group.adm_bastion.id}"]
  }
}


/* Spinnaker SG */
resource "aws_security_group" "infra_spinnaker" {
  vpc_id = "${aws_vpc.main.id}"
  name="INFRA_SPINNAKER"
  description="Spinnaker Security group for ${aws_vpc.main.id}"
  tags {
    Name="INFRA_SPINNAKER"
    created_on="2015-08-03 this date is actually quite invalid"
    created_by="Kenzan terraform"
    application="none"
    allocated="false"
    allocated_on="none"
    owner="none"
  }
  ingress {
    from_port="80"
    to_port="80"
    protocol="tcp"
    cidr_blocks=["0.0.0.0/0"]
  }
}


resource "aws_security_group_rule" "infra_spinnaker_self_referential_rules" {
  type = "ingress"
  from_port = 0
  to_port = 65535
  protocol = "-1"

  security_group_id = "${aws_security_group.infra_spinnaker.id}"
  self = true
}


/* Jenkins SG */
resource "aws_security_group" "infra_jenkins" {
  vpc_id = "${aws_vpc.main.id}"
  name="INFRA_JENKINS"
  description="Jenkins Security group for ${aws_vpc.main.id}"
  tags {
    Name="INFRA_JENKINS"
    created_on="2015-08-03 this date is actually quite invalid"
    created_by="Kenzan terraform"
    application="none"
    allocated="false"
    allocated_on="none"
    owner="none"
  }
  ingress {
    from_port="80"
    to_port="80"
    protocol="tcp"
    cidr_blocks=["0.0.0.0/0"]
  }
}