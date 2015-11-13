#!/usr/bin/env python

"""
Create an application in spinnaker

Usage:
    ./create_application.py (--app_name=<app_name>) (--pipeline_name=<pipeline_name>) [(--spinnaker_address=<spinnaker_address>)]

Options:
    --help Show this screen
    --version Show version
    -s, --spinnaker_address=<spinnaker_address> Address of the spinnaker host
    -a, --app_name=<app_name> Name of the application to add the pipeline too
    -p, --pipeline_name=<pipeline_name> Name of the pipeline to create
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

def main(argv):
    arguments = docopt(__doc__, version=str(
        os.path.basename(__file__)) + " " + VERSION, options_first=False)

    if arguments['--spinnaker_address'] is not None:
        spinnaker_address = arguments['--spinnaker_address']
    else:
        spinnaker_address = SPINNAKER_HOST

    app_name = arguments['--app_name']
    pipeline_name = arguments['--pipeline_name']


    pipeline_json_file = 'pipeline.json'
    app_json_file = 'application.json'


    spin_tools = spinnaker(spinnaker_address=spinnaker_address,
                           spinnaker_port=SPINNAKER_PORT, gate_port=GATE_PORT)
    
    '''
    application = {}
    application['app_name'] = app_name
    application['description'] = "this is a test description"
    application['email'] = 'jpancoast@kenzan.com'
    application['pd_api_key'] = ''
    application['repo_project_key'] = 'Repo Project Name'
    application['repo_name'] = 'Repository Name'
    application['repo_type'] = 'stash'  # stash or github
    '''

    with open(pipeline_json_file) as pipeline_file:
        pipeline = json.load(pipeline_file)

    pipeline['name'] = pipeline_name
    pipeline['application'] = app_name

    with open(app_json_file) as app_file:
        application = json.load(app_file)

    application['app_name'] = app_name


#    pprint(pipeline)

    '''
    pipeline = {}
    stage_1 = {}
    stage_2 = {}

    triggers = []
    stages = []


    stage_1['requisiteStageRefIds'] = []
    stage_1['refId'] = '1'
    stage_1['type'] = 'bake'
    stage_1['name'] = 'Bake'
    stage_1['cloudProviderType'] = 'aws'
    stage_1['regions'] = ['us-west-2']
    stage_1['user'] = 'anonymous'
    stage_1['vmType'] = 'hvm'
    stage_1['storeType'] = 'ebs'
    stage_1['baseOs'] = 'trusty'
    stage_1['baseLabel'] = 'unstable'
    stage_1['showAdvancedOptions'] = True
    stage_1['sendNotifications'] = False
    stage_1['enhancedNetworking'] = False
    stage_1['baseAmi'] = 'ami-46a3b427'
    stage_1['package'] = 'hello-karyon-rxnetty'


    stage_2['requisiteStageRefIds'] = ["1"]
    stage_2['refId'] = "2"
    stage_2['type'] = "deploy"
    stage_2['name'] = "Deploy"

    clusters = []
    cluster_1 = {}
    cluster_1['application'] = app_name
    cluster_1['strategy'] = "highlander"
    cluster_1['capacity'] = { "min": 1, "max": 1, "desired": 1 }
    
    cluster_1['targetHealthyDeployPercentage'] = ''
    cluster_1['cooldown'] = 10
    cluster_1['healthCheckType'] = "EC2"
    cluster_1['healthCheckGracePeriod'] = 600
    cluster_1['instanceMonitoring'] = False
    cluster_1['ebsOptimized'] = False
    cluster_1['iamRole'] = 'BaseIAMRole'

    cluster_1['terminationPolicies'] = ["Default"]

    cluster_1['availabilityZones'] = { "us-west-2": [ "us-west-2a", "us-west-2b", "us-west-2c"]}

    cluster_1['keyPair'] = 'my-aws-account-keypair'

    cluster_1['suspendedProcesses'] = []
    cluster_1['securityGroups'] = ["sg-e1a7ee85"]
    cluster_1['interestingHealthProviderNames'] = [ "Amazon" ]

    cluster_1['subnetType'] = 'ec2'
    cluster_1['virtualizationType'] = None
    cluster_1['instanceType'] = "t2.small"
    cluster_1['stack'] = 'stack'
    cluster_1['freeFormDetails'] = 'Free Form Details'
    cluster_1['provider'] = 'aws'
    cluster_1['cloudProvider'] = 'aws'
    cluster_1['account'] = 'my-aws-account'

    clusters.append(cluster_1)

    stage_2['clusters'] = clusters

    stages.append(stage_1)
    stages.append(stage_2)

    trigger_1 = {}
    trigger_1['enabled'] = True
    trigger_1['type'] = 'jenkins'
    trigger_1['master'] = "Jenkins"
    trigger_1['job'] = "Package_example_app"
    trigger_1['propertyFile'] = ""

    triggers.append(trigger_1)

    pipeline['name'] = pipeline_name
    pipeline['stages'] = stages
    pipeline['triggers'] = triggers
    pipeline['application'] = app_name
    pipeline['stageCounter'] = 0
    pipeline['parallel'] = True
    pipeline['index'] = 0
    '''

    spin_tools.create_application(application)

    spin_tools.create_pipeline(pipeline)

if __name__ == "__main__":
    main(sys.argv)
