#!/bin/sh


#
#	Spinnaker specific stuff
#
mv /tmp/terraform/gce.json /opt/rosco/config/packer/gce.json
sed -i.bak -e "s/<NETWORK>/${1}/" /opt/rosco/config/packer/gce.json

service rosco restart


i=0
tput sc
while fuser /var/lib/dpkg/lock >/dev/null 2>&1 ; do
    case $(($i % 4)) in
        0 ) j="-" ;;
        1 ) j="\\" ;;
        2 ) j="|" ;;
        3 ) j="/" ;;
    esac
    tput rc
    echo "Waiting for other software managers to finish..." 
    sleep 5.0
    ((i=i+1))
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


