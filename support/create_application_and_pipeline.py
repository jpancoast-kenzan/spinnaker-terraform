#!/usr/bin/env python

"""
Create an application in spinnaker

Usage:
    ./create_application.py (--app_name=<app_name>) (--pipeline_name=<pipeline_name>) (--sg_id=<sg_id>) (--vpc_sg_id=<vpc_sg_id>) (--mgmt_sg_id=<mgmt_sg_id>) [(--spinnaker_address=<spinnaker_address>)]

Options:
    --help Show this screen
    --version Show version
    -s, --spinnaker_address=<spinnaker_address> Address of the spinnaker host
    -a, --app_name=<app_name> Name of the application to add the pipeline too
    -p, --pipeline_name=<pipeline_name> Name of the pipeline to create
    -g, --sg_id=<sg_id> ID of the security group to attach.
    -v, --vpc_sg_id=<vpc_sg_id> ID of the VPC SG to attach
    -m, --mgmt_sg_id=<mgmt_sg_id> ID of the MGMT SG to attach
"""

VERSION = '0.1'
SPINNAKER_HOST = 'localhost'
SPINNAKER_PORT = '8080'
GATE_PORT = '8084'

import sys
import os

from pprint import pprint
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

    app_name = arguments['--app_name']
    pipeline_name = arguments['--pipeline_name']
    sg_id = arguments['--sg_id']
    vpc_sg_id = arguments['--vpc_sg_id']
    mgmt_sg_id = arguments['--mgmt_sg_id']

    pipeline_json_file = 'pipeline.json'
    app_json_file = 'application.json'

    spin_tools = spinnaker(spinnaker_address=spinnaker_address,
                           spinnaker_port=SPINNAKER_PORT, gate_port=GATE_PORT)

    with open(pipeline_json_file) as pipeline_file:
        pipeline = json.load(pipeline_file)

    pipeline['name'] = pipeline_name
    pipeline['application'] = app_name

    pipeline['stages'][1]['clusters'][0]['securityGroups'] = [sg_id, vpc_sg_id, mgmt_sg_id]
    with open(app_json_file) as app_file:
        application = json.load(app_file)

    application['app_name'] = app_name

    spin_tools.create_application(application)

    spin_tools.create_pipeline(pipeline)

if __name__ == "__main__":
    main(sys.argv)
