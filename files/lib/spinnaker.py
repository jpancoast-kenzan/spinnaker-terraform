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

'''
TODO:
    Theere is so much code reuse in here it's not even funny.
'''

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
        Cluster deletion takes quite a long time, so we set different timeouts/retries for them.
        '''
        self.cluster_retries = 20
        self.cluster_retry_interval = 20


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

    def cluster(self, cluster, action='delete'):
        verb = 'Deleting '

        if action == 'create':
            verb = 'Creating '

        print verb + 'cluster: ' + cluster['application']

        success = False
        num_tries = 0

        url = 'http://' + self.spinnaker_address + ':' + self.gate_port + \
            '/applications/' + cluster['application'] + '/tasks'

        try:
            headers = {'content-type': 'application/json'}
            r = requests.post(
                url, data=json.dumps(cluster), headers=headers)
        except requests.exceptions.RequestException, e:
            print e
            return False

        ref = r.json()['ref']

        check_url = 'http://' + self.spinnaker_address + ':' + self.gate_port + \
            '/applications/' + cluster['application'] + ref


        while not success and num_tries < self.cluster_retries:
            r = requests.get(check_url, timeout=30.0)
            num_tries += 1

            if action == 'create':
                print "Checking for cluster creation success... " + str(num_tries)
            elif action == 'delete':
                print "Checking for cluster deletion success... " + str(num_tries)

            if r.json()['status'] == 'SUCCEEDED':
                print "\tSuccess!"
                success = True
            else:
                time.sleep(self.cluster_retry_interval)

        if not success:
            self.error_response = r

        return success



    def load_balancer(self, loadbalancer, action='create'):
        verb = 'Creating '

        if action == 'delete':
            verb = 'Deleting '

        print verb + 'load_balancer: ' + loadbalancer['application']

        success = False
        num_tries = 0

        url = 'http://' + self.spinnaker_address + ':' + self.gate_port + \
            '/applications/' + loadbalancer['application'] + '/tasks'

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


        while not success and num_tries < self.retries:
            r = requests.get(check_url, timeout=30.0)
            num_tries += 1

            if action == 'create':
                print "Checking for LB creation success... " + str(num_tries)
            elif action == 'delete':
                print "Checking for LB deletion success... " + str(num_tries)

            if r.json()['status'] == 'SUCCEEDED':
                print "\tSuccess!"
                success = True
            else:
                time.sleep(self.retry_interval)

        if not success:
            self.error_response = r

        return success



    '''
    Wait until 8084 is listening
    '''
    def wait_for_8084(self):
        print "Waiting for port 8084..."

        url = 'http://localhost:8084'

        listening_on_8084 = False
        num_tries = 0

        while not listening_on_8084 and num_tries < self.retries:
            try:
                r = requests.get(url, timeout=10.0)

                num_tries += 1

                if r.status_code == requests.codes.ok:
                    listening_on_8084 = True
            except:
                pass


    '''
    OK, objective: make 'create_application' just like the others, pass in a json blob with all the information already
    '''
    def create_application(self, application):
        print "Creating application: " + application['application']
        app_create_success = False
        num_tries = 0

        url = 'http://' + self.spinnaker_address + ':' + self.gate_port + \
            '/applications/' + application['application'] + '/tasks'

        print "Attempting to create application..." + url

        try:
            headers = {'content-type': 'application/json'}
            r = requests.post(url, data=json.dumps(application), headers=headers)
        except requests.exceptions.RequestException, e:
            print e
            return False

        ref = r.json()['ref']

        check_url = 'http://' + self.spinnaker_address + ':' + self.gate_port + \
            '/applications/' + application['application'] + ref

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

