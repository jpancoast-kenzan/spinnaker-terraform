
#
#	This is a non working key, just in case we forget to change it and it gets out.
#
resource "aws_key_pair" "ssh_key" {
  key_name = "${var.ssh_key_name}"
  public_key = "${var.ssh_public_key}"
}

