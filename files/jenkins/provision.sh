#!/bin/sh

#
#	Not sure why this is needed. Chad's script(s) set it, so I will too
#
DEBIAN_FRONTEND=noninteractive apt-get -yq upgrade

#
#	Download the keys for the apt repositories we're going to add in just a bit.
#
#apt-key adv --keyserver keys.gnupg.net --recv-keys $1
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $3
wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -


#
#	add some fancy repos
#
echo "deb http://pkg.jenkins-ci.org/debian binary/" > /etc/apt/sources.list.d/jenkins.list
echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" > /etc/apt/sources.list.d/webupd8team-java.list
add-apt-repository -y ppa:openjdk-r/ppa

#
#	Install some packages...
#
apt-get update
apt-get -y install jenkins nginx unzip git openjdk-8-jdk htop

#
#	Create/move/copy/fix permissions on all the configs that are needed
#
mv /tmp/terraform/jenkins_config.xml /var/lib/jenkins/config.xml
chown jenkins:jenkins /var/lib/jenkins/config.xml

#mv /tmp/terraform/jenkins.model.JenkinsLocationConfiguration.xml /var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml

mkdir -p /var/lib/jenkins/users/tempaccount/
chown jenkins:jenkins /var/lib/jenkins/users/
mv /tmp/terraform/tempaccount_config.xml /var/lib/jenkins/users/tempaccount/config.xml
chown -f jenkins:jenkins /var/lib/jenkins/users/* -R


#
#	Setup trivial debian repo
#
apt-get install -y --force-yes dpkg-dev
mkdir -p /opt/deb_repo/binary
chown jenkins:jenkins /opt/deb_repo/
chown jenkins:jenkins -R /opt/deb_repo/*


update-rc.d jenkins enable
/etc/init.d/jenkins start

mv /tmp/terraform/nginx.conf /etc/nginx/sites-available/default
mkdir /var/log/nginx/jenkins/
chown www-data /var/log/nginx/jenkins/

#mv /tmp/terraform/provision_base_ami /usr/bin/
#chmod a+x /usr/bin/provision_base_ami


#
#	Install packer
#
curl -L $4 > /tmp/terraform/packer.zip
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

#
#	OR find all the jobs in the jobs/ dir and install them all
#
for job_xml in $(find /tmp/terraform/jobs/ -name config.xml -print)
do
	sleep 2
	job_name=$(echo $job_xml | sed -e 's/\/tmp\/terraform\/jobs\///' | sed -e 's/\/config.xml//')

	/usr/bin/java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:8080/ create-job $job_name < $job_xml
done


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
echo "jenkins.model.Jenkins.instance.securityRealm.createAccount(\"$1\", \"$2\")" | java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:8080/ groovy =

rm -rf /var/lib/jenkins/users/tempaccount/
/usr/bin/java -jar /tmp/terraform/jenkins-cli.jar -s http://localhost:8080/ reload-configuration

update-rc.d nginx enable
/etc/init.d/nginx restart


#
#	clean up /tmp/terraform/
#
rm -rf /tmp/terraform*

