#!/usr/bin/env python

import pprint
import json
import time


try:
    import requests
except ImportError, e:
    print "Missing requests module.  Install with: sudo pip install requests"
    print "If you don't have pip, do this first: sudo easy_install pip"
    exit(2)


class spinnaker():

    def __init__(self, spinnaker_address):
        print "init, baby!"

        self.spinnaker_address = spinnaker_address

        self.pp = pprint.PrettyPrinter(indent=4)
        self.retries = 5
        self.retry_interval = 2  # in seconds...

    '''
    curl 'http://52.32.241.219/gate/applications/jpancoast.test.3/tasks' \
        -H 'Origin: http://52.32.241.219' \
        -H 'Content-Type: application/json;charset=UTF-8' \
        -H 'Accept: application/json, text/plain, */*' \
        -H 'Referer: http://52.32.241.219/' \
        --data-binary '{"suppressNotification":true,"job":[{"type":"createApplication","account":"default","application":{"name":"jpancoast.test.3","description":"description","email":"jpancoast@kenzan.com","pdApiKey":"pagerdutyapikey","repoProjectKey":"repoprojectname","repoSlug":"reponame","repoType":"stash","cloudProviders":"","platformHealthOnly":true,"platformHealthOnlyShowOverride":true},"user":"[anonymous]"}],"application":"jpancoast.test.3","description":"Create Application: jpancoast.test.3"}' 
    
    '''

    def create_pipeline(self, pipeline):
        self.pp.pprint(pipeline)

    def create_application(self, application):
        print "Create Application"

        app_create_success = False
        num_tries = 0

        payload = {}
        payload['suppressNotification'] = True
        payload['application'] = application['app_name']
        payload['description'] = 'Create Application: ' + \
            application['app_name']
        payload['job'] = []

        job = {}
        job['user'] = 'anonymous'
        job['type'] = 'createApplication'
        job['account'] = 'default'

        job['application'] = {}
        job['application']['name'] = application['app_name']
        job['application']['description'] = application['description']
        job['application']['email'] = application['email']
        job['application']['pdApiKey'] = application['pd_api_key']
        job['application']['repoProjectKey'] = application['repo_project_key']
        job['application']['repoSlug'] = application['repo_name']
        job['application']['repoType'] = application['repo_type']
        job['application']['cloudProviders'] = ''
        job['application']['platformHealthOnly'] = True
        job['application']['platformHealthOnlyShowOverride'] = True

        payload['job'].append(job)

        url = 'http://' + self.spinnaker_address + \
            '/gate/applications/' + application['app_name'] + '/tasks'

        print "Attempting to create application..."

        try:
            r = requests.post(url, json=payload)
        except requests.exceptions.RequestException, e:
            print e
            return False

        ref = r.json()['ref']

        check_url = 'http://' + self.spinnaker_address + \
            '/gate/applications/' + application['app_name'] + ref

        '''
        busy waiting is the awesomest. Since I sorta do actually want this to block.
        '''
        while not app_create_success and num_tries < self.retries:
            r = requests.get(check_url)
            num_tries += 1

            print "Checking for app creation success... " + str(num_tries)

            if r.json()['status'] == 'SUCCEEDED':
                print "\tSuccess!"
                app_create_success = True
            else:
                time.sleep(self.retry_interval)

        return app_create_success
