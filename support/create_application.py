#!/usr/bin/env python

import sys

from spinnaker import spinnaker


#
#def create_application(self, app_name, description, email, pd_api_key, repo_project_key, repo_name, repo_type):

def main(argv):
    spin_tools = spinnaker( spinnaker_address='52.26.81.34' )

    app_name = "jpancoast.test.script"
    description = "this is a test description"
    email = 'jpancoast@kenzan.com'
    pd_api_key = ''
    repo_project_key = 'Repo Project Name'
    repo_name = 'Repository Name'
    repo_type = 'stash' #stash or github

    spin_tools.create_application(app_name=app_name, description=description, email=email, pd_api_key=pd_api_key, repo_project_key=repo_project_key, repo_name=repo_name, repo_type=repo_type)


if __name__ == "__main__":
    main(sys.argv)
