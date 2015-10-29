#!/bin/sh

#
#	Not sure why this is needed. Chad's script(s) set it, so I will too
#
DEBIAN_FRONTEND=noninteractive apt-get -yq upgrade

#
#	Download the keys for the apt repositories we're going to add in just a bit.
#
apt-key adv --keyserver keys.gnupg.net --recv-keys $1
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $4
wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -


#
#	add some fancy repos
#
echo "deb http://pkg.jenkins-ci.org/debian binary/" > /etc/apt/sources.list.d/jenkins.list
echo "deb http://repo.aptly.info/ squeeze main" > /etc/apt/sources.list.d/aptly.list
echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" > /etc/apt/sources.list.d/webupd8team-java.list
add-apt-repository -y ppa:openjdk-r/ppa

#
#	Install some packages...
#
apt-get update
apt-get -y install jenkins aptly nginx unzip git openjdk-7-jdk openjdk-8-jdk htop

#
#	Create/move/copy/fix permissions on all the configs that are needed
#
mv /tmp/terraform/config.xml /var/lib/jenkins/config.xml
chown jenkins:jenkins /var/lib/jenkins/config.xml

mkdir -p /var/lib/jenkins/users/tempaccount/
chown jenkins:jenkins /var/lib/jenkins/users/
mv /tmp/terraform/tempaccount_config.xml /var/lib/jenkins/users/tempaccount/config.xml
chown -f jenkins:jenkins /var/lib/jenkins/users/* -R

mv /tmp/terraform/aptly.conf /etc/aptly.conf

mkdir -p /opt/aptly

update-rc.d jenkins enable
/etc/init.d/jenkins start

mv /tmp/terraform/nginx.conf /etc/nginx/sites-available/default
mv /tmp/terraform/provision_base_ami /usr/bin/
chmod a+x /usr/bin/provision_base_ami


#
#	Install packer
#
curl -L $5 > /tmp/terraform/packer.zip
sudo unzip /tmp/terraform/packer.zip -d /usr/bin
 

#
#	Get ready to install Jenkins plugins
#    
sudo mkdir -p /var/lib/jenkins/updates
sudo chown jenkins:jenkins /var/lib/jenkins/updates/
sudo chmod 0755 /var/lib/jenkins/updates/
curl -L https://updates.jenkins-ci.org/update-center.json | sed '1d;$d' > /tmp/terraform/default.json
sudo mv /tmp/terraform/default.json /var/lib/jenkins/updates/default.json
sudo chown jenkins:jenkins /var/lib/jenkins/updates/default.json
sudo chmod 0755 /var/lib/jenkins/updates/default.json

sleep 60

cd /tmp/terraform/ ; curl -O http://localhost:8080/jnlpJars/jenkins-cli.jar

#
#	'tempaccount' is a temporary account, obviously, and will be deleted at the end of this script after a fresh
#		'admin' account has been created with credentials provided in terraform.tfvars
#
java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:8080/ login --username tempaccount --password blah123

#
#	Install jenkins plugins
#
/usr/bin/java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:8080/ install-plugin chucknorris
/usr/bin/java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:8080/ install-plugin git
/usr/bin/java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:8080/ install-plugin github-api
/usr/bin/java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:8080/ install-plugin github
/usr/bin/java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:8080/ install-plugin git-parameter
/usr/bin/java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:8080/ install-plugin job-dsl
/usr/bin/java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:8080/ install-plugin parameterized-trigger
/usr/bin/java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:8080/ install-plugin shelve-project-plugin
/usr/bin/java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:8080/ install-plugin ssh
/usr/bin/java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:8080/ install-plugin swarm
/usr/bin/java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:8080/ install-plugin credentials-binding
/usr/bin/java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:8080/ install-plugin workflow-step-api
/usr/bin/java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:8080/ install-plugin ws-cleanup
/usr/bin/java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:8080/ install-plugin plain-credentials
/usr/bin/java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:8080/ install-plugin postbuildscript

/usr/bin/java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:8080/ create-job dsl-ami-provisioning < /tmp/terraform/dsl-ami-provisioning-job.xml


#/usr/bin/java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:8080/ reload-configuration

#
#	Restart jenkins...
#
/etc/init.d/jenkins restart

sleep 60

#cd /tmp/terraform/ ; java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:8080/ login --username tempaccount --password blah123


#
#	Create admin user, delete tempaccount, and reload jenkins config
#
echo "jenkins.model.Jenkins.instance.securityRealm.createAccount(\"$2\", \"$3\")" | java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:8080/ groovy =
/usr/bin/java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:8080/ build dsl-ami-provisioning

rm -rf /var/lib/jenkins/users/tempaccount/
/usr/bin/java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:8080/ reload-configuration

update-rc.d nginx enable
/etc/init.d/nginx restart


#
#	clean up /tmp/terraform/
#
rm -rf /tmp/terraform/

