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
#	This is only for testing, should not be needed when meta package is done.
#
#cd /home/ubuntu/build && ../spinnaker/dev/run_dev.sh

################## Everything below this line is probably not needed and should MOSTLY be covered by the meta package install ###############
#
#usermod -a -G docker ubuntu
##usermod -a -G docker spinnaker
#
#DEBIAN_FRONTEND='noninteractive apt-get -yq upgrade'
#
#apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $1
#apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys $2
#
#echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" > /etc/apt/sources.list.d/webupd8team-java.list
#echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list
#echo "deb https://spinnaker.bintray.com/ospackages /" > /etc/apt/sources.list.d/spinnaker-bintray.list
#echo "deb http://jenkins.kenzan.int:8000/ binary/" > /etc/apt/sources.list.d/deb-internal.list
#
#add-apt-repository -y ppa:openjdk-r/ppa 
#
#apt-get clean
#apt-get update
#
#apt-get install -y git zip python-support curl openjdk-8-jdk htop software-properties-common python-software-properties awscli
#
##
##	Install spinnaker packages from bintray. 'force-yes' is required as noone seems to know the key...
##
##apt-get install --force-yes -y clouddriver front50 gate orca rosco rush spinnaker echo
#
##docker
##	lxc-docker didn't work for some reason...
##apt-get --yes --force-yes install lxc-docker
#apt-get install -y docker-engine
#
#update-alternatives --config java
#update-alternatives --config javac
#java -version
#
## Start up the docker registry
#docker run -d -p 5000:5000 --restart=always --name registry registry:2
#
#
###aws
##sudo mkdir /home/ubuntu/.aws
##
##mv /home/ubuntu/aws.config /home/ubuntu/.aws/config
##sudo chmod 600 /home/ubuntu/.aws/config
##
##rm /home/ubuntu/build/RELEASE/deck_settings.js
##cp settings.js /home/ubuntu/build/RELEASE/deck_settings.js
##
##rm /home/ubuntu/build/RELEASE/clouddriver-local.yml
##cp clouddriver.yml /home/ubuntu/build/RELEASE/clouddriver-local.yml
##
##rm /home/ubuntu/build/RELEASE/default_spinnaker_config.cfg
##cp spinnaker.cfg /home/ubuntu/build/RELEASE/default_spinnaker_config.cfg
##
##chmod -R 0777 /home/ubuntu/.spinnaker
##chmod 600 /home/ubuntu/.spinnaker/spinnaker_config.cfg




#Should clean up /tmp/terraform here...
#rm -rf /tmp/terraform/