#
# BaseIAMRole, the IAM role spinnaker requires.
#
resource "aws_iam_role" "base_iam_role" {
  name = "${var.base_iam_role_name}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
     "Action": "sts:AssumeRole",
      "Principal": {
       "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
     "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "base_iam_role_profile" {
  name = "${var.base_iam_role_name}_profile"
  roles = ["${aws_iam_role.base_iam_role.id}"]
}

#
# Jenkins role
#
resource "aws_iam_role" "jenkins_role" {
  name = "${var.jenkins_iam_role_name}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
     "Action": "sts:AssumeRole",
      "Principal": {
       "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
     "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_role_policy" "jenkins_policy" {
  name = "jenkins_policy"
  role = "${aws_iam_role.jenkins_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "NotAction": "iam:*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "jenkins_instance_profile" {
  name = "jenkins_profile"
  roles = ["${aws_iam_role.jenkins_role.id}"]
}



#
# Default role for everything else (logging, etc.)
#
resource "aws_iam_role" "properties_and_logging_role" {
  name = "${var.properties_and_logging_iam_role_name}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
     "Action": "sts:AssumeRole",
      "Principal": {
       "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
     "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "tagging_policy" {
  name = "tagging_policy"
  role = "${aws_iam_role.properties_and_logging_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1394163459000",
      "Effect": "Allow",
      "Action": [
        "ec2:CreateTags",
        "ec2:DescribeImages",
        "ec2:DescribeTags"
      ],
      "Resource":"*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "properties_and_logging_instance_profile" {
  name = "properties_and_logging_profile"
  roles = ["${aws_iam_role.properties_and_logging_role.id}"]
}

#
# Spinnaker, the new hotness
#

# Don't think we actually need a spinnaker user...
resource "aws_iam_user" "spinnaker" {
  name = "spinnaker"
  path = "/system/"
}

#resource "aws_iam_access_key" "spinnaker" {
#    user = "${aws_iam_user.spinnaker.name}"
#}

resource "aws_iam_user_policy" "spinnaker" {
    name = "spinnaker"
    user = "${aws_iam_user.spinnaker.name}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "NotAction": "iam:*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "spinnaker_role" {
  name = "${var.spinnaker_iam_role_name}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
     "Action": "sts:AssumeRole",
      "Principal": {
       "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
     "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_role_policy" "spinnaker_admin_policy" {
  name = "spinnaker_admin_policy"
  role = "${aws_iam_role.spinnaker_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "spinnaker_instance_profile" {
  name = "spinnaker_profile"
  roles = ["${aws_iam_role.spinnaker_role.id}"]

}
#
# End Spinnaker
#
