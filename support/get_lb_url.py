#!/usr/bin/env python

import sys
import pprint
import os
import time

try:
    import boto.ec2.autoscale
except ImportError, e:
    print "Missing boto module.  Install with: sudo pip install boto"
    print "If you don't have pip, do this first: sudo easy_install pip"
    exit(2)

try:
    import boto.ec2.elb
except ImportError, e:
    print "Missing boto module.  Install with: sudo pip install boto"
    print "If you don't have pip, do this first: sudo easy_install pip"
    exit(2)

try:
    import requests
except ImportError, e:
    print "Missing requests module.  Install with: sudo pip install requests"
    print "If you don't have pip, do this first: sudo easy_install pip"
    exit(2)

def main(argv):
    pp = pprint.PrettyPrinter(indent=4)

    if len(sys.argv) != 3:
        print "You need to give me the region and vpc_id. In that order."
        exit(1)

    region = sys.argv[1]
    vpc_id = sys.argv[2]

    num_tries = 20
    request_timeout = 10.0

    elb_conn = boto.ec2.elb.connect_to_region(region)

    lbs = elb_conn.get_all_load_balancers()

    lb_found = False

    for lb in lbs:
        if lb.vpc_id == vpc_id:
            if str(lb.dns_name).startswith('testappname-teststack-testdetail'):
                lb_url = "http://" + str(lb.dns_name)
                lb_found = True

    if lb_found:
        print "Attempting to determine health of: " + lb_url + ". NOTE: This could take awhile."
        successful_load = False
        current_try = 1

        while not successful_load and current_try < num_tries:
            print "Try #" + str(current_try)
            current_try += 1
            r_lb = requests.get(lb_url + "/healthcheck", timeout=request_timeout)
            if r_lb.status_code == requests.codes.ok:
                successful_load = True
                print "\tSUCCESS!"

            else:
                print "\tWaiting another " + str(request_timeout) + " seconds..."
                time.sleep(request_timeout)

        if successful_load:
            print "\n\nGo to the following URL in your brower to see the example app you just deployed:"
            print "\t" + lb_url + "/hello"
        else:
            print lb_url + " is not healthy. It does take some time for the instance to show up as healthy in the LB, you might want to try again in a few minutes."
    else:
        print "NO LB could be found for the test application in Region: " + region + ", VPC_ID: " + vpc_id

if __name__ == "__main__":
    main(sys.argv)
