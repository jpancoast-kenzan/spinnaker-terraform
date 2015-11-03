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
        self.retry_interval = 2 #in seconds...

    '''
    curl 'http://52.32.241.219/gate/applications/jpancoast.test.3/tasks' \
        -H 'Origin: http://52.32.241.219' \
        -H 'Content-Type: application/json;charset=UTF-8' \
        -H 'Accept: application/json, text/plain, */*' \
        -H 'Referer: http://52.32.241.219/' \
        --data-binary '{"suppressNotification":true,"job":[{"type":"createApplication","account":"default","application":{"name":"jpancoast.test.3","description":"description","email":"jpancoast@kenzan.com","pdApiKey":"pagerdutyapikey","repoProjectKey":"repoprojectname","repoSlug":"reponame","repoType":"stash","cloudProviders":"","platformHealthOnly":true,"platformHealthOnlyShowOverride":true},"user":"[anonymous]"}],"application":"jpancoast.test.3","description":"Create Application: jpancoast.test.3"}' 
    

    {
    "suppressNotification": true,
    "job": [
        {
            "type": "createApplication",
            "account": "default",
            "application": {
                "name": "jpancoast.test.3",
                "description": "description",
                "email": "jpancoast@kenzan.com",
                "pdApiKey": "pagerdutyapikey",
                "repoProjectKey": "repoprojectname",
                "repoSlug": "reponame",
                "repoType": "stash",
                "cloudProviders": "",
                "platformHealthOnly": true,
                "platformHealthOnlyShowOverride": true
            },
            "user": "[anonymous]"
        }
    ],
    "application": "jpancoast.test.3",
    "description": "Create Application: jpancoast.test.3"
    }
    '''

    '''
    This call checks the status of the task creation:
    curl 'http://52.26.81.34/gate/applications/blah/tasks/02d16559-85a6-4382-8298-733c11b6b7ac' 
    -H 'DNT: 1' 
    -H 'Accept-Encoding: gzip, deflate, sdch' 
    -H 'Accept-Language: en-US,en;q=0.8' 
    -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.80 Safari/537.36' 
    -H 'Accept: application/json, text/plain, */*' 
    -H 'Referer: http://52.26.81.34/' 
    -H 'Connection: keep-alive' 
    --compressed


{   u'buildTime': 1446574702497,
    u'endTime': 1446574702552,
    u'execution': {   u'appConfig': {   },
                      u'application': u'jpancoast.test.script',
                      u'authentication': {   u'allowedAccounts': None,
                                             u'user': None},
                      u'buildTime': 1446574702497,
                      u'canceled': False,
                      u'description': u'Create Application: jpancoast.test.script',
                      u'endTime': 1446574702552,
                      u'executingInstance': u'ip-172-30-0-101',
                      u'executionStatus': u'NOT_STARTED',
                      u'id': u'e0fdd9d7-3cb7-4c92-9e10-2cb6cbb07512',
                      u'limitConcurrent': False,
                      u'parallel': False,
                      u'stages': [   {   u'context': {   u'account': u'default',
                                                         u'application': {   u'cloudProviders': u'',
                                                                             u'description': u'this is a test description',
                                                                             u'email': u'jpancoast@kenzan.com',
                                                                             u'name': u'jpancoast.test.script',
                                                                             u'pdApiKey': u'',
                                                                             u'platformHealthOnly': True,
                                                                             u'platformHealthOnlyShowOverride': True,
                                                                             u'repoProjectKey': u'Repo Project Name',
                                                                             u'repoSlug': u'Repository Name',
                                                                             u'repoType': u'stash'},
                                                         u'application.name': u'jpancoast.test.script',
                                                         u'batch.task.id.createApplication': 99,
                                                         u'batch.task.id.stageEnd': 100,
                                                         u'batch.task.id.stageStart': 98,
                                                         u'newState': {   u'accounts': u'default',
                                                                          u'cloudProviders': u'',
                                                                          u'createTs': None,
                                                                          u'description': u'this is a test description',
                                                                          u'email': u'jpancoast@kenzan.com',
                                                                          u'group': None,
                                                                          u'monitorBucketType': None,
                                                                          u'name': u'jpancoast.test.script',
                                                                          u'owner': None,
                                                                          u'pdApiKey': u'',
                                                                          u'regions': None,
                                                                          u'repoProjectKey': u'Repo Project Name',
                                                                          u'repoSlug': u'Repository Name',
                                                                          u'repoType': u'stash',
                                                                          u'tags': None,
                                                                          u'type': None,
                                                                          u'updateTs': None},
                                                         u'notification.type': u'upsertapplication',
                                                         u'previousState': {   },
                                                         u'stageDetails': {   u'endTime': 1446574702538,
                                                                              u'isSynthetic': False,
                                                                              u'name': None,
                                                                              u'startTime': 1446574702508,
                                                                              u'type': u'createApplication'},
                                                         u'user': u'anonymous'},
                                         u'endTime': 1446574702552,
                                         u'id': u'e0ac3a50-0d25-44d7-8bd0-c5daa4961a54',
                                         u'immutable': False,
                                         u'initializationStage': False,
                                         u'name': None,
                                         u'parentStageId': None,
                                         u'refId': None,
                                         u'requisiteStageRefIds': None,
                                         u'scheduledTime': 0,
                                         u'startTime': 1446574702508,
                                         u'status': u'SUCCEEDED',
                                         u'syntheticStageOwner': None,
                                         u'tasks': [   {   u'endTime': 1446574702512,
                                                           u'id': u'1',
                                                           u'name': u'stageStart',
                                                           u'startTime': 1446574702509,
                                                           u'status': u'SUCCEEDED'},
                                                       {   u'endTime': 1446574702540,
                                                           u'id': u'2',
                                                           u'name': u'createApplication',
                                                           u'startTime': 1446574702519,
                                                           u'status': u'SUCCEEDED'},
                                                       {   u'endTime': 1446574702553,
                                                           u'id': u'3',
                                                           u'name': u'stageEnd',
                                                           u'startTime': 1446574702549,
                                                           u'status': u'SUCCEEDED'}],
                                         u'type': u'createApplication'}],
                      u'startTime': 1446574702508,
                      u'status': u'SUCCEEDED'},
    u'id': u'e0fdd9d7-3cb7-4c92-9e10-2cb6cbb07512',
    u'name': u'Create Application: jpancoast.test.script',
    u'startTime': 1446574702508,
    u'status': u'SUCCEEDED',
    u'steps': [   {   u'endTime': 1446574702512,
                      u'id': u'1',
                      u'name': u'stageStart',
                      u'startTime': 1446574702509,
                      u'status': u'SUCCEEDED'},
                  {   u'endTime': 1446574702540,
                      u'id': u'2',
                      u'name': u'createApplication',
                      u'startTime': 1446574702519,
                      u'status': u'SUCCEEDED'},
                  {   u'endTime': 1446574702553,
                      u'id': u'3',
                      u'name': u'stageEnd',
                      u'startTime': 1446574702549,
                      u'status': u'SUCCEEDED'}],
    u'variables': [   {   u'key': u'account', u'value': u'default'},
                      {   u'key': u'application',
                          u'value': {   u'cloudProviders': u'',
                                        u'description': u'this is a test description',
                                        u'email': u'jpancoast@kenzan.com',
                                        u'name': u'jpancoast.test.script',
                                        u'pdApiKey': u'',
                                        u'platformHealthOnly': True,
                                        u'platformHealthOnlyShowOverride': True,
                                        u'repoProjectKey': u'Repo Project Name',
                                        u'repoSlug': u'Repository Name',
                                        u'repoType': u'stash'}},
                      {   u'key': u'application.name',
                          u'value': u'jpancoast.test.script'},
                      {   u'key': u'batch.task.id.createApplication',
                          u'value': 99},
                      {   u'key': u'batch.task.id.stageEnd', u'value': 100},
                      {   u'key': u'batch.task.id.stageStart', u'value': 98},
                      {   u'key': u'newState',
                          u'value': {   u'accounts': u'default',
                                        u'cloudProviders': u'',
                                        u'createTs': None,
                                        u'description': u'this is a test description',
                                        u'email': u'jpancoast@kenzan.com',
                                        u'group': None,
                                        u'monitorBucketType': None,
                                        u'name': u'jpancoast.test.script',
                                        u'owner': None,
                                        u'pdApiKey': u'',
                                        u'regions': None,
                                        u'repoProjectKey': u'Repo Project Name',
                                        u'repoSlug': u'Repository Name',
                                        u'repoType': u'stash',
                                        u'tags': None,
                                        u'type': None,
                                        u'updateTs': None}},
                      {   u'key': u'notification.type',
                          u'value': u'upsertapplication'},
                      {   u'key': u'previousState', u'value': {   }},
                      {   u'key': u'stageDetails',
                          u'value': {   u'endTime': 1446574702538,
                                        u'isSynthetic': False,
                                        u'name': None,
                                        u'startTime': 1446574702508,
                                        u'type': u'createApplication'}},
                      {   u'key': u'user', u'value': u'anonymous'}]}


    '''

    def create_application(self, app_name, description, email, pd_api_key, repo_project_key, repo_name, repo_type):
        print "Create Application"

        app_create_success = False
        num_tries = 0

        payload = {}
        payload['suppressNotification'] = True
        payload['application'] = app_name
        payload['description'] = 'Create Application: ' + app_name
        payload['job'] = []

        job = {}
        job['user'] = 'anonymous'
        job['type'] = 'createApplication'
        job['account'] = 'default'

        job['application'] = {}
        job['application']['name'] = app_name
        job['application']['description'] = description
        job['application']['email'] = email
        job['application']['pdApiKey'] = pd_api_key
        job['application']['repoProjectKey'] = repo_project_key
        job['application']['repoSlug'] = repo_name
        job['application']['repoType'] = repo_type
        job['application']['cloudProviders'] = ''
        job['application']['platformHealthOnly'] = True
        job['application']['platformHealthOnlyShowOverride'] = True

        payload['job'].append(job)


#        self.pp.pprint(headers)
#        print "---------------"
#        self.pp.pprint(payload)

        url = 'http://' + self.spinnaker_address + '/gate/applications/' + app_name + '/tasks'

#        print url

        print "Attempting to create application..."

        try:
            r = requests.post(url, json=payload)
        except requests.exceptions.RequestException, e:
            print e

#        print r.json()

        ref = r.json()['ref']

#        print "Ref: " + ref

        check_url = 'http://' + self.spinnaker_address + '/gate/applications/' + app_name + ref
#        print check_url

        '''
        busy waiting is the awesomest. Since I sorta do actually want this to block.
        '''
        while not app_create_success and num_tries < self.retries:
            r = requests.get(check_url)
            num_tries += 1

            print "Checking for app creation success... " + str(num_tries)

            if r.json()['status'] == 'SUCCEEDED':
                app_create_success = True
            else:
                time.sleep(self.retry_interval)

        return app_create_success
#        print "-------"
#        self.pp.pprint(r.json())