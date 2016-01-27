#!/usr/bin/env python

"""
Create an application in spinnaker

Usage:
    ./create_application.py (--app_name=<app_name>) (--pipeline_name=<pipeline_name>) (--vpc_id=<vpc_id>) (--sg_id=<sg_id>) (--aws_region=<aws_region>) (--vpc_name=<vpc_name>) (--vpc_sg_id=<vpc_sg_id>) (--mgmt_sg_id=<mgmt_sg_id>) (--iam_role=<iam_role>) [(--spinnaker_address=<spinnaker_address>)]

Options:
    --help Show this screen
    --version Show version
    -s, --spinnaker_address=<spinnaker_address> Address of the spinnaker host
    -a, --app_name=<app_name> Name of the application to add the pipeline too
    -p, --pipeline_name=<pipeline_name> Name of the pipeline to create
    -g, --sg_id=<sg_id> ID of the security group to attach.
    -v, --vpc_sg_id=<vpc_sg_id> ID of the VPC SG to attach
    -m, --mgmt_sg_id=<mgmt_sg_id> ID of the MGMT SG to attach
    -n, --vpc_name=<vpc_name> Name of the VPC
    -i, --vpc_id=<vpc_id> VPC ID.
    -r, --aws_region=<aws_region> AWS region
    -o, --iam_role=<iam_role> IAM role for the instance
"""

VERSION = '0.1'
SPINNAKER_HOST = 'localhost'
SPINNAKER_PORT = '9000'
GATE_PORT = '8084'

import sys
import os
import re
import pprint

import boto.vpc

'''
This is only required for when running locally
'''
sys.path.append('../../lib')

from spinnaker import spinnaker

try:
    import json
except ImportError, e:
    print "Missing json module. Install with: sudo pip install json"
    print "If you don't have pip, do this first: sudo easy_install pip"
    exit(2)

try:
    from docopt import docopt
except ImportError, e:
    print "Missing docopt module.  Install with: sudo pip install docopt"
    print "If you don't have pip, do this first: sudo easy_install pip"
    exit(2)


'''
Note:
right now, some stuff is hardcoded in the .json files (like security groups), Those need to be passed in.
'''


def main(argv):
    arguments = docopt(__doc__, version=str(
        os.path.basename(__file__)) + " " + VERSION, options_first=False)

    if arguments['--spinnaker_address'] is not None:
        spinnaker_address = arguments['--spinnaker_address']
    else:
        spinnaker_address = SPINNAKER_HOST

    pp = pprint.PrettyPrinter(indent=4)

    app_name = arguments['--app_name']
    pipeline_name = arguments['--pipeline_name']
    sg_id = arguments['--sg_id']
    aws_region = arguments['--aws_region']
    vpc_id = arguments['--vpc_id']
    vpc_sg_id = arguments['--vpc_sg_id']
    mgmt_sg_id = arguments['--mgmt_sg_id']
    vpc_name = arguments['--vpc_name']
    iam_role = arguments['--iam_role']

    pipeline_json_file = 'pipeline_create.json'
    app_json_file = 'application_create.json'
    lb_json_file = 'loadbalancer_create.json'

    pipeline = {}
    application = {}
    loadbalancer = {}

    aws_conn = boto.vpc.connect_to_region(aws_region)

    spin_tools = spinnaker(spinnaker_address=spinnaker_address,
                           spinnaker_port=SPINNAKER_PORT, gate_port=GATE_PORT)

    with open(pipeline_json_file) as pipeline_file:
        pipeline = json.load(pipeline_file)

    with open(app_json_file) as app_file:
        application = json.load(app_file)

    with open(lb_json_file) as lb_file:
        loadbalancer = json.load(lb_file)

    stack = 'teststack'
    detail = 'testdetail'

    '''
    Get the subnet information
    '''
    subnet_type = pipeline['stages'][1]['clusters'][0]['subnetType']

    tag_name_filter = vpc_name + "." + \
        re.sub("\ \(.*\)", '', subnet_type) + "." + aws_region

    try:
        all_subnets = aws_conn.get_all_subnets(
            filters={'vpc_id': vpc_id, 'tag:Name': tag_name_filter})
    except Exception, e:
        print "ERROR: Could not connect to AWS. Check your aws keys."
        exit(1)

    subnet_azs = [s.availability_zone for s in all_subnets]

    if len(subnet_azs) == 1:
        print "No subnets found!"
        exit(1)

    '''
    Configure the special load balancer vars
    '''
    loadbalancer['job'][0]['stack'] = stack
    loadbalancer['job'][0]['detail'] = detail

    loadbalancer['job'][0]['vpcId'] = vpc_id
    loadbalancer['job'][0]['region'] = aws_region
    loadbalancer['job'][0]['name'] = app_name + '-' + stack + '-' + detail
    loadbalancer['job'][0]['subnetType'] = "eelb_public (" + vpc_name + ")"

    loadbalancer['job'][0]['availabilityZones'][aws_region] = subnet_azs
    loadbalancer['job'][0]['regionZones'] = subnet_azs

    loadbalancer['application'] = app_name
    loadbalancer['description'] = 'Create Load Balancer: ' + \
        loadbalancer['job'][0]['name']

    '''
    Configure the special pipeline vars
    '''

    pipeline['name'] = pipeline_name

    pipeline['stages'][1]['clusters'][0][
        'subnetType'] = "ec2_public (" + vpc_name + ")"

    pipeline['stages'][1]['clusters'][0]['iamRole'] = iam_role + '_profile'

    pipeline['stages'][1]['clusters'][0][
        'securityGroups'] = [sg_id, vpc_sg_id, mgmt_sg_id]

    pipeline['stages'][1]['clusters'][0][
        'loadBalancers'] = [app_name + '-' + stack + '-' + detail]

    pipeline['stages'][1]['clusters'][0]['application'] = app_name
    pipeline['stages'][1]['clusters'][0]['stack'] = stack

    pipeline['stages'][0]['regions'] = [aws_region]

    pipeline['stages'][1]['clusters'][0][
        'availabilityZones'][aws_region] = subnet_azs

    pipeline['name'] = pipeline_name
    pipeline['application'] = app_name

    '''
    Set the special applicaiton vars
    '''
    application['job'][0]['application']['name'] = app_name
    application['application'] = app_name
    application['description'] = 'Create Application: ' + app_name

    spin_tools.wait_for_8084()


    if spin_tools.create_application(application):
        if spin_tools.load_balancer(loadbalancer):
            if spin_tools.create_pipeline(pipeline):
                print "Everything created successfully."
            else:
                print "Pipeline creation failed."
                pp.pprint(pipeline)
                print spin_tools.error_response
        else:
            print "Load Balancer Creation failed, not continuing."
            pp.pprint(loadbalancer)
    else:
        print "Application creation failed, not continuing."
        pp.pprint(application)
    

if __name__ == "__main__":
    main(sys.argv)
