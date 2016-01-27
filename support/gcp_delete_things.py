#!/usr/bin/env python

VERSION = '0.1'
SPINNAKER_HOST = 'localhost'
SPINNAKER_PORT = '9000'
GATE_PORT = '8084'

import sys
import pprint
import os
import time

sys.path.append('../files/lib')

from spinnaker import spinnaker


try:
    import json
except ImportError, e:
    print "Missing json module. Install with: sudo pip install json"
    print "If you don't have pip, do this first: sudo easy_install pip"
    exit(2)


def main(argv):
    pp = pprint.PrettyPrinter(indent=4)

    if len(sys.argv) != 3:
        print "You need to give me the region and the zone. In that order."
        exit(1)

    region = sys.argv[1]
    zone = sys.argv[2]

    spinnaker_address = SPINNAKER_HOST
    
    cluster_json_file = '../files/gcp/spinnaker-and-jenkins/cluster_delete.json'
    load_balancer_json_file = '../files/gcp/spinnaker-and-jenkins/loadbalancer_delete.json'

    cluster = {}
    load_balancer = {}

    with open(cluster_json_file) as cluster_file:
        cluster = json.load(cluster_file)

    with open(load_balancer_json_file) as lb_file:
        load_balancer = json.load(lb_file)

    spin_tools = spinnaker(spinnaker_address=spinnaker_address,
                           spinnaker_port=SPINNAKER_PORT, gate_port=GATE_PORT)

    '''
    Set the cluster variables
    '''
    cluster['job'][0]['region'] = region
    cluster['job'][0]['regions'] = [ region ]
    cluster['job'][0]['zone'] = region + '-' + zone
    cluster['job'][0]['zones'] = [ region + '-' + zone ]

    '''
    Set the load_balancer variables
    '''
    load_balancer['job'][0]['region'] = region
    load_balancer['job'][0]['regions'] = [ region ]

    '''
    print '----'
    pp.pprint(cluster)
    print '----'
    pp.pprint(load_balancer)
    print '----'
    '''

    if spin_tools.cluster(cluster, action='delete'):
        print "Cluster deletion successful..."
    else:
        print "Cluster deletion failed."
        print spin_tools.error_response

    if spin_tools.load_balancer(load_balancer, action='delete'):
        print "Load Balancer deletion successful..."
    else:
        print "Load Balancer Deletion failed."
        print spin_tools.error_response

if __name__ == "__main__":
    main(sys.argv)