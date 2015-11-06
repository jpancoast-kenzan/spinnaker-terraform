#!/usr/bin/env python


"""
Create an application in spinnaker

Usage:
    ./create_application.py (--spinnaker_address=<spinnaker_address>) (--app_name=<app_name>) (--pipeline_name=<pipeline_name>)

Options:
    --help Show this screen
    --version Show version
    -s, --spinnaker_address=<spinnaker_address> Address of the spinnaker host
    -a, --app_name=<app_name> Name of the application to add the pipeline too
    -p, --pipeline_name=<pipeline_name> Name of the pipeline to add the stage too
"""

VERSION = '0.1'

import sys
import os

from spinnaker import spinnaker

try:
    from docopt import docopt
except ImportError, e:
    print "Missing docopt module.  Install with: sudo pip install docopt"
    print "If you don't have pip, do this first: sudo easy_install pip"
    exit(2)

#
# def create_application(self, app_name, description, email, pd_api_key,
# repo_project_key, repo_name, repo_type):
#
def main(argv):
    arguments = docopt(__doc__, version=str(os.path.basename(__file__)) + " " + VERSION, options_first=False)

    spinnaker_address = arguments['--spinnaker_address']
    app_name = arguments['--app_name']
    pipeline_name = arguments['--pipeline_name']

    spin_tools = spinnaker(spinnaker_address=spinnaker_address)

#    pipeline = {}
#
#    app_name = "jpancoast.test.script"


#   '{"name":"pipeline-name","stages":[],"triggers":[],"application":"jpancoast.test.script","stageCounter":0,"parallel":true,"index":0}'

    '''
    pipeline['name'] = 'pipeline-name-2'
    pipeline['stages'] = []
    pipeline['triggers'] = []
    pipeline['application'] = app_name
    pipeline['stageCounter'] = 0
    pipeline['parallel'] = True 
    pipeline['index'] = 0

    spin_tools.create_pipeline(pipeline)
    '''


    spin_tools.create_stage()

    
if __name__ == "__main__":
    main(sys.argv)