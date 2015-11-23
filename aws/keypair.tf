
resource "aws_key_pair" "ssh_key" {
  key_name = "${var.ssh_key_name}"
  public_key = "${file("${var.ssh_public_key_location}")}"
}