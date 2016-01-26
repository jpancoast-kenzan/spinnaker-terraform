#!/usr/bin/env python

import sys
import pprint
import os
import time

try:
    import requests
except ImportError, e:
    print "Missing requests module.  Install with: sudo pip install requests"
    print "If you don't have pip, do this first: sudo easy_install pip"
    exit(2)

#r_lb = requests.get(lb_url + "/healthcheck", timeout=request_timeout)
def main(argv):
    pp = pprint.PrettyPrinter(indent=4)

    num_tries = 20
    request_timeout = 10.0

    lb_found = False

    app_name = 'testappname' #Hardcoded for now, shouldn't be a problem to hardocde it as long as scripts create the applicaiton, lb, etc.
    cloud_provider = sys.argv[1]
    lb_name = sys.argv[2]
    lb_listen_port = sys.argv[3]

    spinnaker_lb_url = 'http://localhost:8084/applications/' + app_name + '/loadBalancers'

    r_find_lb = requests.get(spinnaker_lb_url, timeout=request_timeout)

    lbs = r_find_lb.json()

    for lb in lbs:
        if lb['name'] == lb_name:
            if cloud_provider == 'aws':
                lb_address = lb['canonicalHostedZoneName']
            elif cloud_provider == 'gcp':
                lb_address = lb['ipAddress']

            lb_found = True



    if lb_found:
        lb_url = 'http://' + lb_address + ':' + lb_listen_port + '/hello'

        print "Attempting to determine health of: " + lb_url + ". NOTE: This could take awhile."
        successful_load = False
        current_try = 1

        while not successful_load and current_try < num_tries:
            print "Try #" + str(current_try)
            current_try += 1

            try:
                r_lb = requests.get(lb_url, timeout=request_timeout)
                if r_lb.status_code == requests.codes.ok:
                    successful_load = True
                    print "\tSUCCESS!"

                else:
                    print "\tWaiting another " + str(request_timeout) + " seconds..."
                    time.sleep(request_timeout)
            except:
                print "The port is probably not listening or open. Check your firewall rules."

        if successful_load:
            print "\n\nGo to the following URL in your brower to see the example app you just deployed:"
            print "\t" + lb_url
        else:
            print lb_url + " is not healthy. It does take some time for the instance to show up as healthy in the LB, you might want to try again in a few minutes."

    else:
        print "NO LB could be found for the test application."


if __name__ == "__main__":
    main(sys.argv)
