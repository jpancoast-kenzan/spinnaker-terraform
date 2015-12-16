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

    def __init__(self, spinnaker_address, spinnaker_port, gate_port):
        print "init, baby!"

        self.spinnaker_address = spinnaker_address
        self.spinnaker_port = spinnaker_port
        self.gate_port = gate_port

        self.pp = pprint.PrettyPrinter(indent=4)
        self.retries = 10
        self.retry_interval = 2  # in seconds...
        self.error_response = None

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
        -H 'Connection: keep-alive' 
        -H 'DNT: 1' 
        --data-binary '{"index":0,"name":"appnamepipeline","stageCounter":0,"triggers":[{"enabled":true,"type":"jenkins","master":"Jenkins","job":"Package_example_app"}],"application":"appname","stages":[],"parallel":true,"id":"9bfb3400-88ce-11e5-bf5b-9d3eb09d9db6"}' --compressed
    
    curl 'http://localhost:8084/pipelines' -X OPTIONS -H 'Access-Control-Request-Method: POST' -H 'Origin: http://localhost:8080' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: en-US,en;q=0.8' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.80 Safari/537.36' -H 'Accept: */*' -H 'Referer: http://localhost:8080/' -H 'Connection: keep-alive' -H 'DNT: 1' -H 'Access-Control-Request-Headers: accept, content-type' --compressed
    '''
    '''
    {
    "index": 0,
    "name": "appnamepipeline",
    "stageCounter": 0,
    "triggers": [
        {
            "enabled": true,
            "type": "jenkins",
            "master": "Jenkins",
            "job": "Package_example_app"
        }
    ],
    "application": "appname",
    "stages": [],
    "parallel": true,
    "id": "9bfb3400-88ce-11e5-bf5b-9d3eb09d9db6"
    }
    '''

    def create_trigger(self, trigger):
        print "Creating Trigger"

        '''
        This returns nothing in the response, just headers, so don't go looking for nothing if it's not in the headers
        '''
        url = 'http://' + self.spinnaker_address + ':' + self.gate_port + \
            '/pipelines'

        try:
            headers = {'content-type': 'application/json'}
            r = requests.post(url, data=json.dumps(trigger), headers=headers)
        except requests.exceptions.RequestException, e:
            print e
            return False

    '''
    curl 'http://52.26.81.34/gate/pipelines' 
    -H 'Origin: http://52.26.81.34' 
    -H 'Accept-Encoding: gzip, deflate' 
    -H 'Accept-Language: en-US,en;q=0.8' 
    -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.80 Safari/537.36' 
    -H 'Content-Type: application/json;charset=UTF-8' 
    -H 'Accept: application/json, text/plain, */*' 
    -H 'Referer: http://52.26.81.34/' 
    -H 'Connection: keep-alive' -H 'DNT: 1' 
    --data-binary '{"name":"pipeline-name","stages":[],"triggers":[],"application":"kenzan.test.script","stageCounter":0,"parallel":true,"index":0}' --compressed
    '''

    def create_pipeline(self, pipeline):
        print "Creating pipeline: " + pipeline['name']

        '''
        This returns nothing in the response, just headers, so don't go looking for nothing if it's not in the headers
        '''
        url = 'http://' + self.spinnaker_address + ':' + self.gate_port + \
            '/pipelines'

        try:
            headers = {'content-type': 'application/json'}
            r = requests.post(url, data=json.dumps(pipeline), headers=headers)
        except requests.exceptions.RequestException, e:
            self.error_response = r
            print e
            return False

        return True

    '''
    curl 'http://localhost:8084/applications/testappname/tasks'
    '''

    def create_load_balancer(self, loadbalancer):
        print "Creating load_balancer: " + loadbalancer['application']
        lb_create_success = False
        num_tries = 0

        url = 'http://' + self.spinnaker_address + ':' + self.gate_port + \
            '/applications/testappname/tasks'

        try:
            headers = {'content-type': 'application/json'}
            r = requests.post(
                url, data=json.dumps(loadbalancer), headers=headers)
        except requests.exceptions.RequestException, e:
            print e
            return False

        ref = r.json()['ref']

        check_url = 'http://' + self.spinnaker_address + ':' + self.gate_port + \
            '/applications/' + loadbalancer['application'] + ref

        '''
        busy waiting is the awesomest. Since I sorta do actually want this to block.
        TODO: put this in a method
        '''
        while not lb_create_success and num_tries < self.retries:
            r = requests.get(check_url, timeout=30.0)
            num_tries += 1

            print "Checking for LB creation success... " + str(num_tries)

            if r.json()['status'] == 'SUCCEEDED':
                print "\tSuccess!"
                lb_create_success = True
            else:
                time.sleep(self.retry_interval)

        if not lb_create_success:
            self.error_response = r

        return lb_create_success

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
        # default value for now, probably shouldn't hard code it
        job['account'] = 'my-aws-account'

        job['application'] = {}
        job['application']['name'] = application['app_name']
        job['application']['description'] = application['description']
        job['application']['email'] = application['email']
        job['application']['pdApiKey'] = application['pd_api_key']
        job['application']['repoProjectKey'] = application['repo_project_key']
        job['application']['repoSlug'] = application['repo_name']
        job['application']['repoType'] = application['repo_type']
        job['application']['cloudProviders'] = 'aws'
        job['application']['platformHealthOnly'] = True
        job['application']['platformHealthOnlyShowOverride'] = True

        payload['job'].append(job)

        url = 'http://' + self.spinnaker_address + ':' + self.gate_port + \
            '/applications/' + application['app_name'] + '/tasks'

        print "Attempting to create application..." + url

        try:
            headers = {'content-type': 'application/json'}
            r = requests.post(url, data=json.dumps(payload), headers=headers)
        except requests.exceptions.RequestException, e:
            print e
            return False

        ref = r.json()['ref']

        check_url = 'http://' + self.spinnaker_address + ':' + self.gate_port + \
            '/applications/' + application['app_name'] + ref

        '''
        busy waiting is the awesomest. Since I sorta do actually want this to block.
        '''
        while not app_create_success and num_tries < self.retries:
            r = requests.get(check_url, timeout=30.0)
            num_tries += 1

            print "Checking for app creation success... " + str(num_tries)

            if r.json()['status'] == 'SUCCEEDED':
                print "\tSuccess!"
                app_create_success = True
            else:
                time.sleep(self.retry_interval)

        if not app_create_success:
            self.error_response = r

        return app_create_success

    '''
    Curl to create the first stage:
    curl 'http://ec2-52-26-72-234.us-west-2.compute.amazonaws.com/8084/pipelines' 
        -H 'Origin: http://ec2-52-26-72-234.us-west-2.compute.amazonaws.com' 
        -H 'Accept-Encoding: gzip, deflate' 
        -H 'Accept-Language: en-US,en;q=0.8' 
        -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.80 Safari/537.36' 
        -H 'Content-Type: application/json;charset=UTF-8' 
        -H 'Accept: application/json, text/plain, */*' 
        -H 'Referer: http://ec2-52-26-72-234.us-west-2.compute.amazonaws.com/' 
        -H 'Connection: keep-alive' 
        -H 'DNT: 1' --data-binary '{"name":"pipelinetest","stages":[{"requisiteStageRefIds":[],"refId":"1","type":"bake","name":"Bake","cloudProviderType":"aws","regions":["us-west-2"],"user":"[anonymous]","vmType":"hvm","storeType":"ebs","baseOs":"trusty","baseLabel":"unstable","showAdvancedOptions":true,"baseAmi":"ami-8ee605bd","package":"echo"}],"triggers":[{"enabled":true,"type":"jenkins","master":"Jenkins","job":"Package_example_app"}],"application":"appnme","limitConcurrent":true,"stageCounter":1,"parallel":true,"index":0,"id":"b4f3c970-84de-11e5-832e-77b4d230fd64"}' --compressed
    '''

    def create_stage(self, something):
        print "Creating stage"
