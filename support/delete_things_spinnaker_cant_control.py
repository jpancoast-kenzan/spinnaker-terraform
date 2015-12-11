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


    #
    #   Order of ops:
    #       1. Delete all load balancers in the given vpc
    #       2. Delete all auto scalign groups in the given vpc
    #

    elb_conn = boto.ec2.elb.connect_to_region(region)

    lbs = elb_conn.get_all_load_balancers()

    for lb in lbs:
        if lb.vpc_id == vpc_id:
            print "Deleting LB: " + str(lb)
            lb.delete()
    

    asg_conn = boto.ec2.autoscale.connect_to_region(region)
    asgs = asg_conn.get_all_groups()

    for asg in asgs:
        if asg.vpc_id == vpc_id:
            print "Deleting ASG: " + str(asg)
            asg.delete()

if __name__ == "__main__":
    main(sys.argv)