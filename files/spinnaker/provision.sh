#!/bin/sh


##
##	If we need aws keys:
##		"sudo /tmp/terraform/provision.sh ${var.region} ${aws_iam_access_key.spinnaker.id} ${aws_iam_access_key.spinnaker.secret} ${var.internal_dns_zone}"
##"sudo /tmp/terraform/provision.sh ${var.region} ${var.internal_dns_zone}"
#
##
##   We just grab this script and it does everything!
##	Change the download URL with InstallSpinnakerRoscoRush.sh is working...
##curl -L "https://dl.bintray.com/kenzanlabs/spinnaker_scripts/InstallSpinnaker.sh" -o /tmp/terraform/InstallSpinnakerRoscoRush.sh
#curl -L "https://dl.bintray.com/kenzanlabs/spinnaker_scripts/InstallSpinnaker.sh" -o /tmp/terraform/InstallSpinnaker.sh
#chmod a+x /tmp/terraform/InstallSpinnaker.sh
##The following is a hack until the script gets fixed.
#sed -i.bak -e "s/\ \#\!\/bin\/bash/\#\!\/bin\/bash/" /tmp/terraform/InstallSpinnaker.sh
##This is giving an error, module aufs not found
##*** System restart required ***
##Spinnaker is coming up with a cluster already configured, no idea where that came from.
#/tmp/terraform/InstallSpinnaker.sh --cloud_provider amazon --aws_region $1

#
#   Rosco isn't starting up right either.


cp /tmp/terraform/igor-local.yml /opt/spinnaker/config/
sed -i.bak -e "s/JENKINS_URL/http:\/\/jenkins.$2\//" -e "s/JENKINS_USERNAME/$3/" -e "s/JENKINS_PASSWORD/$4/" /opt/spinnaker/config/igor-local.yml

echo "deb http://jenkins.$2:8000/ binary/" > /etc/apt/sources.list.d/deb-internal.list


#
#	modify spinnaker-local.yml to set igor_enabled to True
#
sed -i.bak -e "s/igor_enabled\: false/igor_enabled\: true/" /opt/spinnaker/config/spinnaker-local.yml


service igor start


#chmod a+x /home/ubuntu/.init-region
#/home/ubuntu/.init-region



#http://jenkins.kenzan.int:8000/ binary/
sed -i.bak -e "s/debianRepository: .*/debianRepository: http\:\/\/debianrepo.${2}:8000\/ binary\//" /opt/rosco/config/rosco.yml


#
#   hack hack hack. I need to put specific values into the aws-ebs.json file for vpc id and subnet id
#
#MAC_ADDR=$(curl -s http://169.254.169.254/latest/meta-data/mac)
# VPC to launch instance in
#VPC_ID=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/${MAC_ADDR}/vpc-id)
# Subnet ID to launch instance in (Required in VPC)
#SUBNET_ID=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/${MAC_ADDR}/subnet-id)


#sed -i.bak -e "s/vpc-a6e5a5c3/${VPC_ID}/" -e "s/subnet-ed56219a/${SUBNET_ID}/" /opt/rosco/docker/aws-ebs.json
#
##sudo sed -i.bak -e "s/\"sleep 30\"\,/ \"sleep 30\"\,\\n\"echo \\\"deb/" aws-ebs.json
##                 #https://dl.bintray.com/moondev/spinnaker trusty main\\\" | sudo tee /etc/apt/sources.list.d/spinnaker.list > /dev/null\"\,/" /opt/rosco/docker/aws-ebs.json
#
##      "echo \"deb https://dl.bintray.com/moondev/spinnaker trusty main\" | sudo tee /etc/apt/sources.list.d/spinnaker.list > /dev/null",
#sudo sed -i.bak -e "s/https/http/" -e "s/\/moondev\/spinnaker/\:8000\//" -e "s/trusty main/binary\//" -e "s/dl.bintray.com/jenkins.${2}/" -e "s/spinnaker.list/debrepo.list/" /opt/rosco/docker/aws-ebs.json 
#
#DOCKER_IMAGE_NAME=spinnaker/rosco
#DOCKER_REGISTRY=localhost:5000
#
#docker build -t $DOCKER_IMAGE_NAME .
#docker tag -f $DOCKER_IMAGE_NAME $DOCKER_REGISTRY/$DOCKER_IMAGE_NAME
#docker push $DOCKER_REGISTRY/$DOCKER_IMAGE_NAME

#service rosco restart
#service rush restart

#
#   clean up /tmp/terraform/
#
rm -rf /tmp/terraform*

sleep 5
