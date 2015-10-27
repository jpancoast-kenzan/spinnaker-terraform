#!/bin/sh


apt-key adv --keyserver keys.gnupg.net --recv-keys $1
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C2518248EEA14886
wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -

echo "deb http://pkg.jenkins-ci.org/debian binary/" > /etc/apt/sources.list.d/jenkins.list
echo "deb http://repo.aptly.info/ squeeze main" > /etc/apt/sources.list.d/aptly.list
echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" > /etc/apt/sources.list.d/webupd8team-java.list
add-apt-repository -y ppa:openjdk-r/ppa

apt-get update
apt-get -y install jenkins aptly nginx unzip git openjdk-7-jdk openjdk-8-jdk

mkdir -p /var/lib/jenkins/jobs/dsl-ami-provisioning/
mv /tmp/terraform/dsl-ami-provisioning-job.xml /var/lib/jenkins/jobs/dsl-ami-provisioning/

chown jenkins:jenkins /var/lib/jenkins/jobs/
chown jenkins:jenkins /var/lib/jenkins/jobs/* -R

mv /tmp/terraform/jenkins_config.xml /var/lib/jenkins/config.xml
chown jenkins:jenkins /var/lib/jenkins/config.xml

mkdir -p /var/lib/jenkins/users/tempaccount/
chown jenkins:jenkins /var/lib/jenkins/users/
mv /tmp/terraform/jenkins_tempaccount_config.xml /var/lib/jenkins/users/tempaccount/config.xml
chown -f jenkins:jenkins /var/lib/jenkins/users/* -R


update-rc.d jenkins enable
/etc/init.d/jenkins start
mv /tmp/terraform/nginx_jenkins.conf /etc/nginx/sites-available/default
mv /tmp/terraform/provision_base_ami /usr/bin/
chmod a+x /tmp/terraform/provision_base_ami


curl -L https://dl.bintray.com/mitchellh/packer/packer_0.8.6_linux_amd64.zip > /tmp/terraform/packer.zip
sudo unzip /tmp/terraform/packer.zip -d /usr/bin
     
sudo mkdir -p /var/lib/jenkins/updates
sudo chown jenkins:jenkins /var/lib/jenkins/updates/
sudo chmod 0755 /var/lib/jenkins/updates/
curl -L https://updates.jenkins-ci.org/update-center.json | sed '1d;$d' > /tmp/terraform/default.json
sudo mv /tmp/terraform/default.json /var/lib/jenkins/updates/default.json
sudo chown jenkins:jenkins /var/lib/jenkins/updates/default.json
sudo chmod 0755 /var/lib/jenkins/updates/default.json

sleep 120

cd /tmp/terraform/ ; curl -O http://localhost:8080/jnlpJars/jenkins-cli.jar

#
#	'tempaccount' is a temporary account, obviously, and will be deleted at the end of this script after a fresh
#		'admin' account has been created with credentials provided in terraform.tfvars
#
java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:8080/ login --username tempaccount --password blah123

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

update-rc.d nginx enable
/etc/init.d/nginx restart
/etc/init.d/jenkins restart

sleep 120

cd /tmp/terraform/ ; java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:8080/ login --username tempaccount --password blah123

#admin/admin123 should be passed in variables
echo "jenkins.model.Jenkins.instance.securityRealm.createAccount(\"$2\", \"$3\")" | java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:8080/ groovy =
/usr/bin/java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:8080/ build dsl-ami-provisioning

rm -rf /var/lib/jenkins/users/tempaccount/
java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:8080/ reload-configuration

#Should clean up /tmp/terraform here...
rm -rf /tmp/terraform/

