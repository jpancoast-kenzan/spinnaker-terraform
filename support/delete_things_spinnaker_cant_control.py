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

try:
    import boto.vpc
except ImportError, e:
    print "Missing boto module.  Install with: sudo pip install boto"
    print "If you don't have pip, do this first: sudo easy_install pip"
    exit(2)


def get_all_launch_configs(conn):
    all_launch_configs = {}

    nextToken = "start"

    while nextToken is not None:
        if nextToken == 'start':
            lcs = conn.get_all_launch_configurations(max_records=100)
        else:
            lcs = conn.get_all_launch_configurations(
                max_records=100, next_token=nextToken)

        for lc in lcs:
            all_launch_configs[lc.name] = lc

        if len(all_launch_configs) % 100 == 0:
            nextToken = lcs.next_token
        else:
            nextToken = None

    return all_launch_configs

def main(argv):
    pp = pprint.PrettyPrinter(indent=4)

    if len(sys.argv) != 3:
        print "You need to give me the region and vpc_id. In that order."
        exit(1)

    region = sys.argv[1]
    vpc_id = sys.argv[2]

    subnets = {}
    asgs_to_delete = {}


    asg_conn = boto.ec2.autoscale.connect_to_region(region)
    aws_conn = boto.vpc.connect_to_region(region)


    #
    #   Order of ops:
    #       1. Get a list of all the subnets in the VPC. This will be used later on to delete the ASG's
    #       2. Get a list of all the SGs in the VPC
    #       1. Delete all load balancers in the given vpc
    #       2. Delete all auto scalign groups in the given vpc
    #       3. Delete any unused launch configs (maybe)
    #

    all_launch_configs = get_all_launch_configs(asg_conn)

    for lc_name in all_launch_configs:
        lc = all_launch_configs[lc_name]
        print lc.security_groups

    try:
        all_subnets = aws_conn.get_all_subnets(
            filters={'vpc_id': vpc_id})
    except Exception, e:
        print "ERROR: Could not connect to AWS. Check your aws keys."
        exit(1)

    for s in all_subnets:
        subnets[s.id] = None

    elb_conn = boto.ec2.elb.connect_to_region(region)

    lbs = elb_conn.get_all_load_balancers()

    for lb in lbs:
        if lb.vpc_id == vpc_id:
            print "Deleting LB: " + str(lb)
#            lb.delete()
    

    asgs = asg_conn.get_all_groups()

    for asg in asgs:
        for zone_id in str(asg.vpc_zone_identifier).split(','):
            if zone_id in subnets:
                asgs_to_delete[asg.name] = asg

    for asg_name in asgs_to_delete:
        asg_to_delete = asgs_to_delete[asg_name]

        print "Deleting ASG: " + asg_to_delete.name
#        asg_to_delete.delete()

if __name__ == "__main__":
    main(sys.argv)

