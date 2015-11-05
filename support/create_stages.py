#!/usr/bin/env python

import sys

from spinnaker import spinnaker


#
# def create_application(self, app_name, description, email, pd_api_key,
# repo_project_key, repo_name, repo_type):
#
def main(argv):
    spin_tools = spinnaker(spinnaker_address='52.33.42.42')

    pipeline = {}

    app_name = "jpancoast.test.script"


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