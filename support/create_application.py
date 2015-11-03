#!/usr/bin/env python

import sys

from spinnaker import spinnaker


#
# def create_application(self, app_name, description, email, pd_api_key,
# repo_project_key, repo_name, repo_type):

def main(argv):
    spin_tools = spinnaker(spinnaker_address='52.26.81.34')

    application = {}
    pipeline = {}

    application['app_name'] = "jpancoast.test.script"
    application['description'] = "this is a test description"
    application['email'] = 'jpancoast@kenzan.com'
    application['pd_api_key'] = ''
    application['repo_project_key'] = 'Repo Project Name'
    application['repo_name'] = 'Repository Name'
    application['repo_type'] = 'stash'  # stash or github

    spin_tools.create_application(application)

    spin_tools.create_pipeline(pipeline)

if __name__ == "__main__":
    main(sys.argv)
