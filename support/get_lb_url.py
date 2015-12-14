#!/usr/bin/env python

import sys
import pprint
import os

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



def main(argv):
    pp = pprint.PrettyPrinter(indent=4)

    if len(sys.argv) != 3:
        print "You need to give me the region and vpc_id. In that order."
        exit(1)

    region = sys.argv[1]
    vpc_id = sys.argv[2]

    elb_conn = boto.ec2.elb.connect_to_region(region)

    lbs = elb_conn.get_all_load_balancers()

    for lb in lbs:
        if lb.vpc_id == vpc_id:
            print "Enter the following URL into a browser: " + str(lb.dns_name)

if __name__ == "__main__":
    main(sys.argv)