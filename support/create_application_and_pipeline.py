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
SPINNAKER_PORT = '8080' #I could probably put these in a yaml config file or something.
GATE_PORT = '8084'

import sys
import os

from spinnaker import spinnaker

try:
    from docopt import docopt
except ImportError, e:
    print "Missing docopt module.  Install with: sudo pip install docopt"
    print "If you don't have pip, do this first: sudo easy_install pip"
    exit(2)

'''
curl 'http://localhost:8084/pipelines' 
    -H 'Origin: http://localhost:8080' 
    -H 'Accept-Encoding: gzip, deflate' 
    -H 'Accept-Language: en-US,en;q=0.8' 
    -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.80 Safari/537.36' 
    -H 'Content-Type: application/json;charset=UTF-8' 
    -H 'Accept: application/json, text/plain, */*' 
    -H 'Referer: http://localhost:8080/' 
    -H 'Cookie: PLAY_SESSION=01d09ca7710d8ea9c16349e16d578065c86f7677-sessionid=b140299f82252baeca13b5e4b40308c21199303dec55c4e909e08a9415e17df99412aeb84cadb4397e3dc5e2c4cba38d' 
    -H 'Connection: keep-alive' -H 'DNT: 1' 
    --data-binary '{"index":0,"name":"appnamepipeline","stageCounter":1,"triggers":[{"type":"jenkins","job":"Package_example_app","enabled":true,"propertyFile":"propertyFile","master":"Jenkins"}],"application":"appname","stages":[{"requisiteStageRefIds":[],"refId":"1","type":"bake","name":"Bake","cloudProviderType":"aws","regions":["us-west-2"],"user":"[anonymous]","vmType":"hvm","storeType":"ebs","baseOs":"trusty","baseLabel":"unstable","showAdvancedOptions":true,"sendNotifications":false,"enhancedNetworking":false,"baseAmi":"ami-46a3b427","package":"hello-karyon-rxnetty"}],"parallel":true,"id":"5373ab60-88d1-11e5-bf5b-9d3eb09d9db6"}' --compressed
'''
'''
"stages": [
        {
            "requisiteStageRefIds": [],
            "refId": "1",
            "type": "bake",
            "name": "Bake",
            "cloudProviderType": "aws",
            "regions": [
                "us-west-2"
            ],
            "user": "[anonymous]",
            "vmType": "hvm",
            "storeType": "ebs",
            "baseOs": "trusty",
            "baseLabel": "unstable",
            "showAdvancedOptions": true,
            "sendNotifications": false,
            "enhancedNetworking": false,
            "baseAmi": "ami-46a3b427",
            "package": "hello-karyon-rxnetty"
        }
    ],
'''
#
# def create_application(self, app_name, description, email, pd_api_key,
# repo_project_key, repo_name, repo_type):
#
def main(argv):
    arguments = docopt(__doc__, version=str(os.path.basename(__file__)) + " " + VERSION, options_first=False)

    if arguments['--spinnaker_address'] is not None:
        spinnaker_address = arguments['--spinnaker_address']
    else:
        spinnaker_address = SPINNAKER_HOST

    app_name = arguments['--app_name']
    pipeline_name = arguments['--pipeline_name']

    spin_tools = spinnaker(spinnaker_address=spinnaker_address, spinnaker_port=SPINNAKER_PORT, gate_port=GATE_PORT)


    pipeline = {}
    application = {}
    stage_1 = {}
    stage_2 = {}

    triggers = []
    stages = []




    application['app_name'] = app_name
    application['description'] = "this is a test description"
    application['email'] = 'jpancoast@kenzan.com'
    application['pd_api_key'] = ''
    application['repo_project_key'] = 'Repo Project Name'
    application['repo_name'] = 'Repository Name'
    application['repo_type'] = 'stash'  # stash or github


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


    stages.append(stage_1)
#    stages.append(stage_2)

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


    spin_tools.create_application(application)


    spin_tools.create_pipeline(pipeline)

if __name__ == "__main__":
    main(sys.argv)
