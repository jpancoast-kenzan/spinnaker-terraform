#!/bin/sh



cp /tmp/terraform/igor-local.yml /opt/spinnaker/config/
sed -i.bak -e "s/JENKINS_URL/http:\/\/jenkins.$2\//" -e "s/JENKINS_USERNAME/$3/" -e "s/JENKINS_PASSWORD/$4/" /opt/spinnaker/config/igor-local.yml

echo "deb http://jenkins.$2:8000/ binary/" > /etc/apt/sources.list.d/deb-internal.list


#
#	modify spinnaker-local.yml to set igor_enabled to True
#
sed -i.bak -e "s/igor_enabled\: false/igor_enabled\: true/" /opt/spinnaker/config/spinnaker-local.yml


service igor start

#
#	The bakes, in this environment, need to use the local debian repository
#
sed -i.bak -e "s/# debianRepository: .*/debianRepository: http\:\/\/debianrepo.${2}:8000\/ binary\//" /opt/rosco/config/rosco.yml

#
#	Set the default region in settings.js and restart apache
#
sed -i.bak -e "s/let awsDefaultRegion = '.*'\;/let awsDefaultRegion = '$1'\;/" /var/www/settings.js
sudo service apache2 restart


sleep 5
