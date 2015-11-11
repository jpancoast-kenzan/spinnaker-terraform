#!/bin/sh


#
#	If we need aws keys:
#		"sudo /tmp/terraform/provision.sh ${var.region} ${aws_iam_access_key.spinnaker.id} ${aws_iam_access_key.spinnaker.secret} ${var.internal_dns_zone}"
#"sudo /tmp/terraform/provision.sh ${var.region} ${var.internal_dns_zone}"

#
#   We just grab this script and it does everything!
#
curl -L "https://dl.bintray.com/kenzanlabs/spinnaker_scripts/InstallSpinnaker.sh" -o /tmp/terraform/InstallSpinnaker.sh
chmod a+x /tmp/terraform/InstallSpinnaker.sh
/tmp/terraform/InstallSpinnaker.sh y $1

#
#   Rosco isn't starting up right either.


cp /tmp/terraform/igor-local.yml /opt/spinnaker/config/
sed -i.bak -e "s/JENKINS_URL/http:\/\/jenkins.$2\//" -e "s/JENKINS_USERNAME/$3/" -e "s/JENKINS_PASSWORD/$4/" /opt/spinnaker/config/igor-local.yml

#sed -i.bak -e "s/false/true/" -e "s/us-west-2/$defaultRegion/" /etc/default/spinnaker
#
#defaultMaster:
#      name: Jenkins # The display name for this server
#      baseUrl: JENKINS_URL
#      username: JENKINS_USERNAME
#      password: JENKINS_PASSWORD


#
#	Supposedly aws credentials are not needed... we'll see about that!
#
##Change the ofllowing username to spinnaker when we get the spinnaker meta package working.
#spinnaker_user="ubuntu"
#mkdir -p /home/$spinnaker_user/.aws/
#echo "[default]" > /home/$spinnaker_user/.aws/credentials
#echo "aws_access_key_id = $3" >> /home/$spinnaker_user/.aws/credentials
#echo "aws_secret_access_key = $4" >> /home/$spinnaker_user/.aws/credentials
#
#chown $spinnaker_user /home/$spinnaker_user/.aws/
#chown $spinnaker_user /home/$spinnaker_user/.aws/*

echo "deb http://jenkins.$2:8000/ binary/" > /etc/apt/sources.list.d/deb-internal.list



#
#   clean up /tmp/terraform/
#
rm -rf /tmp/terraform*