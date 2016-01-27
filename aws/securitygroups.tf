
/* ADM_BASTION */
resource "aws_security_group" "adm_bastion" {
  vpc_id = "${aws_vpc.main.id}"
  name="ADM_BASTION"
  description="Bastion Host SG"
  tags {
    Name="ADM_BASTION"
    created_by="${var.created_by}"
    application="none"
    allocated="false"
    allocated_on="none"
    owner="none"
  }
}

/* security group for eelb  */
resource "aws_security_group" "eelb" {
  vpc_id = "${aws_vpc.main.id}"
  name="EELB"
  description="security group for eelb"
  tags {
    Name="EELB"
    created_by="${var.created_by}"
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
    created_by="${var.created_by}"
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
    created_by="${var.created_by}"
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
  egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks=["8.0.0.0/7"]
  }
  egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks=["0.0.0.0/5"]
  }
  egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks=["11.0.0.0/8"]
  }
  egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks=["12.0.0.0/6"]
  }
  egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks=["16.0.0.0/4"]
  }
  egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks=["32.0.0.0/3"]
  }
  egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks=["64.0.0.0/2"]
  }
  egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks=["128.0.0.0/3"]
  }
  egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks=["160.0.0.0/5"]
  }
  egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks=["168.0.0.0/6"]
  }
  egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks=["172.0.0.0/12"]
  }
  egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks=["172.32.0.0/11"]
  }
  egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks=["172.64.0.0/10"]
  }
  egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks=["172.128.0.0/9"]
  }
  egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks=["173.0.0.0/8"]
  }
  egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks=["174.0.0.0/7"]
  }
  egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks=["176.0.0.0/4"]
  }
  egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks=["192.0.0.0/9"]
  }
  egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks=["192.128.0.0/11"]
  }
  egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks=["192.160.0.0/13"]
  }
  egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks=["192.169.0.0/16"]
  }
  egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks=["192.170.0.0/15"]
  }
  egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks=["192.172.0.0/14"]
  }
  egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks=["192.176.0.0/12"]
  }
  egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks=["192.192.0.0/10"]
  }
  egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks=["193.0.0.0/8"]
  }
  egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks=["194.0.0.0/7"]
  }
  egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks=["196.0.0.0/6"]
  }
  egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks=["200.0.0.0/5"]
  }
  egress {
    from_port="0"
    to_port="0"
    protocol="-1"
    cidr_blocks=["208.0.0.0/4"]
  }
}


/* MGMT SG */
resource "aws_security_group" "mgmt_sg" {
  vpc_id = "${aws_vpc.main.id}"
  name="MGMT_${element(split ("-", "${aws_vpc.main.id}"), 1)}"
  description="MGMT Security group for ${aws_vpc.main.id}"
  tags {
    Name="MGMT_${element(split ("-", "${aws_vpc.main.id}"), 1)}"
    created_by="${var.created_by}"
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
    created_by="${var.created_by}"
    application="none"
    allocated="false"
    allocated_on="none"
    owner="none"
  }
}

/* Jenkins SG */
resource "aws_security_group" "infra_jenkins" {
  vpc_id = "${aws_vpc.main.id}"
  name="INFRA_JENKINS"
  description="Jenkins Security group for ${aws_vpc.main.id}"
  tags {
    Name="INFRA_JENKINS"
    created_by="${var.created_by}"
    application="none"
    allocated="false"
    allocated_on="none"
    owner="none"
  }
  ingress {
    from_port="8000"
    to_port="8000"
    protocol="tcp"
    cidr_blocks=["${var.vpc_cidr}"]
  }
  ingress {
    from_port="80"
    to_port="80"
    protocol="tcp"
    security_groups=["${aws_security_group.infra_spinnaker.id}"]
  }
}


/* SG for example application */
resource "aws_security_group" "example_app" {
  vpc_id = "${aws_vpc.main.id}"
  name="EXAMPLE_SG"
  description="Spinnaker Security group for ${aws_vpc.main.id}"
  tags {
    Name="EXAMPLE_SG"
    created_by="${var.created_by}"
    application="none"
    allocated="false"
    allocated_on="none"
    owner="none"
  }
  ingress {
    from_port="8080"
    to_port="8080"
    protocol="tcp"
    security_groups=["${aws_security_group.eelb.id}"]
  }
}


#
# Creating some rules separately to get around a terraform sg diff bug.
#
resource "aws_security_group_rule" "infra_jenkins_incoming_cidrs" {
  type = "ingress"
  from_port=80
  to_port=80
  cidr_blocks=["${compact(concat(split(",",var.local_ip),split(",",var.infra_jenkins_incoming_cidrs)))}"]
  protocol = "tcp"

  security_group_id = "${aws_security_group.infra_jenkins.id}"
}

resource "aws_security_group_rule" "adm_bastion_incoming_cidrs" {
  type = "ingress"
  from_port=22
  to_port=22
  protocol = "tcp"
  cidr_blocks=["${compact(concat(split(",",var.local_ip),split(",",var.adm_bastion_incoming_cidrs)))}"]

  security_group_id = "${aws_security_group.adm_bastion.id}"
}

resource "aws_security_group_rule" "infra_spinnaker_self_referential_rules" {
  type = "ingress"
  from_port = 0
  to_port = 65535
  protocol = "-1"

  security_group_id = "${aws_security_group.infra_spinnaker.id}"
  self = true
}
