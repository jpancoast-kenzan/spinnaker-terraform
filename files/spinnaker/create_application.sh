#!/bin/sh

#### This block is required for the running of the application and pipeline creation script
sudo apt-get update
sudo apt-get -y install python-pip

sudo pip install boto
sudo pip install docopt


#${var.region} ${aws_vpc.main.id} ${var.base_iam_role_name} ${var.vpc_name} ${aws_security_group.infra_spinnaker.id} ${aws_security_group.vpc_sg.id} ${aws_security_group.mgmt_sg.id}


cd /tmp/terraform/
#/tmp/terraform/create_application_and_pipeline.py -a testappname -p testappnamepipeline -g sg-a6ebd8c2 -i vpc-cde4d4a8 -v sg-daebd8be -m sg-0ae8db6e -n vpc_DIFFNAME -r us-west-2 -o base_iam_role_testing_diff_name_profile

chmod a+x create_application_and_pipeline.py

/tmp/terraform/create_application_and_pipeline.py -a testappname -p testappnamepipeline -r $1 -i $2 -o $3 -n $4 -g $5 -v $6 -m $7