#!/usr/bin/env python

"""
Create an application in spinnaker

Usage:
    ./create_application.py (--app_name=<app_name>) (--pipeline_name=<pipeline_name>) (--region=<region>) (--zone=<zone>) (--network=<network>) (--security_group=<security_group>) [(--spinnaker_address=<spinnaker_address>)]

Options:
    --help Show this screen
    --version Show version
    -s, --spinnaker_address=<spinnaker_address> Address of the spinnaker host
    -a, --app_name=<app_name> Name of the application to add the pipeline too
    -p, --pipeline_name=<pipeline_name> Name of the pipeline to create
    -r, --region=<region> Region we're in
    -n, --network=<network> Network to launch in
    -g, --security_group=<security_group> Security group to use
    -z, --zone=<zone> Zone 
"""

VERSION = '0.1'
SPINNAKER_HOST = 'localhost'
SPINNAKER_PORT = '9000'
GATE_PORT = '8084'

import sys
import os
import re
import pprint

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
    region = arguments['--region']
    zone = arguments['--zone']
    network = arguments['--network']
    security_group = arguments['--security_group']

    pipeline_json_file = 'pipeline_create.json'
    app_json_file = 'application_create.json'
    lb_json_file = 'loadbalancer_create.json'

    pipeline = {}
    application = {}
    loadbalancer = {}

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
    Configure the special lb vars
    '''
    loadbalancer['job'][0]['region'] = region
    loadbalancer['job'][0]['availabilityZones'][region] = []

    '''
    Configure the special pipeline vars
    '''
    pipeline['stages'][1]['clusters'][0]['zone'] = region + '-' + zone
    pipeline['stages'][1]['clusters'][0]['availabilityZones'][region] = [region + '-' + zone]
    pipeline['stages'][1]['clusters'][0]['network'] = network
    pipeline['stages'][1]['clusters'][0]['securityGroups'] = [security_group] 


    spin_tools.wait_for_8084()

    if spin_tools.create_application(application):
        print "Application Creation Successful..."

        if spin_tools.load_balancer(loadbalancer, action='create'):
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