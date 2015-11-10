#!/bin/sh


#region: $3
#access_key: $4
#secret_key: $5
#Internal Domain: $6

#Change the ofllowing username to spinnaker when we get the spinnaker meta package working.
spinnaker_user="ubuntu"
mkdir -p /home/$spinnaker_user/.aws/
echo "[default]" > /home/$spinnaker_user/.aws/credentials
echo "aws_access_key_id = $4" >> /home/$spinnaker_user/.aws/credentials
echo "aws_secret_access_key = $5" >> /home/$spinnaker_user/.aws/credentials

chown $spinnaker_user /home/$spinnaker_user/.aws/
chown $spinnaker_user /home/$spinnaker_user/.aws/*

echo "deb http://jenkins.$6:8000/ binary/" > /etc/apt/sources.list.d/deb-internal.list

#
#   We just grab this script and it does everything!
#
#curl -L "https://dl.bintray.com/kenzanlabs/spinnaker_scripts/InstallSpinnaker.sh" -o /tmp/terraform/InstallSpinnaker.sh
#/tmp/terraform/InstallSpinnaker.sh
