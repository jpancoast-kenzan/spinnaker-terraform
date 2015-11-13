#!/bin/sh


#
#	If we need aws keys:
#		"sudo /tmp/terraform/provision.sh ${var.region} ${aws_iam_access_key.spinnaker.id} ${aws_iam_access_key.spinnaker.secret} ${var.internal_dns_zone}"
#"sudo /tmp/terraform/provision.sh ${var.region} ${var.internal_dns_zone}"

#
#   We just grab this script and it does everything!
#	Change the download URL with InstallSpinnakerRoscoRush.sh is working...
curl -L "https://dl.bintray.com/kenzanlabs/spinnaker_scripts/InstallSpinnaker.sh" -o /tmp/terraform/InstallSpinnakerRoscoRush.sh
chmod a+x /tmp/terraform/InstallSpinnakerRoscoRush.sh
/tmp/terraform/InstallSpinnakerRoscoRush.sh --cloud_provider amazon --default_region $1

#
#   Rosco isn't starting up right either.


cp /tmp/terraform/igor-local.yml /opt/spinnaker/config/
sed -i.bak -e "s/JENKINS_URL/http:\/\/jenkins.$2\//" -e "s/JENKINS_USERNAME/$3/" -e "s/JENKINS_PASSWORD/$4/" /opt/spinnaker/config/igor-local.yml

echo "deb http://jenkins.$2:8000/ binary/" > /etc/apt/sources.list.d/deb-internal.list


#
#	modify spinnaker-local.yml to set igor_enabled to True
#
sed -i.bak -e "s/igor_enabled\: false/igor_enabled\: true/" /opt/spinnaker/config/spinnaker-local.yml


#
#	hack hack hack
#
#mv /var/www /var/www_old
#wget https://bintray.com/artifact/download/spinnaker/ospackages/deck_2.352-3_all.deb
#dpkg -i deck_2.352-3_all.deb
#
#mv /tmp/terraform/settings.js /var/www/settings.js
# end hack 

service igor start

#
#   clean up /tmp/terraform/
#
rm -rf /tmp/terraform*