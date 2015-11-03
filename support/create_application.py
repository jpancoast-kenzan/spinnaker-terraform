#!/usr/bin/env python

import sys

from spinnaker import spinnaker


#
# def create_application(self, app_name, description, email, pd_api_key,
# repo_project_key, repo_name, repo_type):
#
def main(argv):
    spin_tools = spinnaker(spinnaker_address='52.32.114.41')

    application = {}
    pipeline = {}

    app_name = "jpancoast.test.script"

    application['app_name'] = app_name
    application['description'] = "this is a test description"
    application['email'] = 'jpancoast@kenzan.com'
    application['pd_api_key'] = ''
    application['repo_project_key'] = 'Repo Project Name'
    application['repo_name'] = 'Repository Name'
    application['repo_type'] = 'stash'  # stash or github

    spin_tools.create_application(application)

if __name__ == "__main__":
    main(sys.argv)
