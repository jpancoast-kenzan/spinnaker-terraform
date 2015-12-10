resource "aws_route53_zone" "internal" {
	name = "${var.internal_dns_zone}"

	tags = {
		name = "${var.internal_dns_zone}"
		purpose = "Spinnaker"
	}

	vpc_id = "${aws_vpc.main.id}"
	vpc_region = "${var.region}"
}

resource "aws_route53_record" "jenkins" {
	zone_id = "${aws_route53_zone.internal.zone_id}"
	name = "jenkins"
	type = "A"
	ttl = "300"
	records = ["${aws_instance.jenkins.private_ip}"]
}

resource "aws_route53_record" "debianrepo" {
	zone_id = "${aws_route53_zone.internal.zone_id}"
	name = "debianrepo"
	type = "A"
	ttl = "300"
	records = ["${aws_instance.jenkins.private_ip}"]
}

resource "aws_route53_record" "spinnaker" {
	zone_id = "${aws_route53_zone.internal.zone_id}"
	name = "spinnaker"
	type = "A"
	ttl = "300"
	records = ["${aws_instance.spinnaker.private_ip}"]
}