#!/bin/sh


#
#	Spinnaker specific stuff
#
mv /tmp/terraform/gce.json /opt/rosco/config/packer/gce.json
sed -i.bak -e "s/<NETWORK>/${1}/" /opt/rosco/config/packer/gce.json

service rosco restart

#
#   Ok, need to set the proper username and password for jenkins
#

cd /tmp/terraform/
chmod a+x modify_spinnaker_config.py

cp /opt/spinnaker/config/spinnaker-local.yml /opt/spinnaker/config/spinnaker-local.yml.orig
/tmp/terraform/modify_spinnaker_config.py /opt/spinnaker/config/spinnaker-local.yml services:jenkins:defaultMaster:username:$2 services:jenkins:defaultMaster:password:$3

service igor restart

#
#   Have to wait for apt-get -y dist-upgrade to finish.
#
while pgrep apt-get > /dev/null; do 
    echo "Waiting for other software managers to finish..." 
    sleep 10.0
done

#### This block is required for the running of the application and pipeline creation script
sudo apt-get update
sudo apt-get -y install python-pip

sudo pip install docopt

#
#	Jenkins specific stuff
#
cd /tmp/terraform/ ; curl -O http://localhost:9090/jnlpJars/jenkins-cli.jar

java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:9090/ login --username admin --password admin

echo "jenkins.model.Jenkins.instance.securityRealm.createAccount(\"$2\", \"$3\")" | java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:9090/ groovy =

#rm -rf /var/lib/jenkins/users/tempaccount/
#
#	If the given username is something OTHER than admin, delete the admin account
#

if [ "x$2" != "xadmin" ]; then
	rm -rf /var/lib/jenkins/users/admin/
fi

/usr/bin/java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:9090/ reload-configuration
