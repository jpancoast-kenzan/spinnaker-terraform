#!/bin/sh


usermod -a -G docker ubuntu
#usermod -a -G docker spinnaker

DEBIAN_FRONTEND='noninteractive apt-get -yq upgrade'

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $1
apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys $2

echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" > /etc/apt/sources.list.d/webupd8team-java.list
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list
echo "deb https://spinnaker.bintray.com/ospackages /" > /etc/apt/sources.list.d/spinnaker-bintray.list

add-apt-repository -y ppa:openjdk-r/ppa 

apt-get clean
apt-get update

apt-get install -y git zip python-support curl openjdk-8-jdk htop software-properties-common python-software-properties awscli

#docker
#	lxc-docker didn't work for some reason...
#apt-get --yes --force-yes install lxc-docker
apt-get install -y docker-engine

update-alternatives --config java
update-alternatives --config javac
java -version

# Start up the docker registry
docker run -d -p 5000:5000 --restart=always --name registry registry:2


##aws
#sudo mkdir /home/ubuntu/.aws
#
#mv /home/ubuntu/aws.config /home/ubuntu/.aws/config
#sudo chmod 600 /home/ubuntu/.aws/config
#
#rm /home/ubuntu/build/RELEASE/deck_settings.js
#cp settings.js /home/ubuntu/build/RELEASE/deck_settings.js
#
#rm /home/ubuntu/build/RELEASE/clouddriver-local.yml
#cp clouddriver.yml /home/ubuntu/build/RELEASE/clouddriver-local.yml
#
#rm /home/ubuntu/build/RELEASE/default_spinnaker_config.cfg
#cp spinnaker.cfg /home/ubuntu/build/RELEASE/default_spinnaker_config.cfg
#
#chmod -R 0777 /home/ubuntu/.spinnaker
#chmod 600 /home/ubuntu/.spinnaker/spinnaker_config.cfg




#Should clean up /tmp/terraform here...
#rm -rf /tmp/terraform/