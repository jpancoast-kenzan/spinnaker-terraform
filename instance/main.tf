

/* bastion instance */
resource "aws_instance" "bastion" {
  ami = "ami-9eaa1cf6"
  instance_type = "t2.small"
  subnet_id = "${aws_subnet.public_subnet.0.id}"
  security_groups = ["${aws_security_group.infra_bastion.id}"]
  associate_public_ip_address=true
  key_name = "KP_bastion"
  tags = {
    Name = "bastion"
    created_on = "2015-08-03"
    created_by = "Kenzanmedia terraform"
  }
}


