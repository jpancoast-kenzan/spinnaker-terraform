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
    sgs_in_vpc = {}
    lcs_to_delete = {}
    instance_ids_to_terminate = {}

    asg_conn = boto.ec2.autoscale.connect_to_region(region)
    aws_conn = boto.vpc.connect_to_region(region)
    instance_conn = boto.ec2.connect_to_region(region)

    print "Attempting to delete all non-terraform controlled assets in vpc: " + vpc_id
    
    #
    #   Order of ops:
    #       1. Get a list of all the subnets in the VPC. This will be used later on to delete the ASG's
    #       2. Delete all load balancers in the given vpc
    #       3. Delete all auto scalign groups in the given vpc
    #       4. Delete all relevant LC's with the proper name. That's the quickest way to tell if they're in the VPC.
    #

    try:
        all_subnets = aws_conn.get_all_subnets(
            filters={'vpc_id': vpc_id})
    except Exception, e:
        print "ERROR: Could not connect to AWS. Check your aws keys."
        exit(1)

    all_sgs = aws_conn.get_all_security_groups()

    for s in all_subnets:
        subnets[s.id] = None

    elb_conn = boto.ec2.elb.connect_to_region(region)

    lbs = elb_conn.get_all_load_balancers()

    for lb in lbs:
        if lb.vpc_id == vpc_id:
            print "Deleting LB: " + str(lb)
            lb.delete()

    asgs = asg_conn.get_all_groups()

    for asg in asgs:
        for zone_id in str(asg.vpc_zone_identifier).split(','):
            if zone_id in subnets:
                asgs_to_delete[asg.name] = asg


    instances_were_terminated = False
    '''
    First, terminate all instances from the asg.
    '''
    for asg_name in asgs_to_delete:
        asg_to_delete = asgs_to_delete[asg_name]

        print "Terminating instances from ASG: " + asg_to_delete.name
        asg_to_delete.shutdown_instances()
        instances_were_terminated = True

    '''
    Now wait some bit of time if we actually deleted any instances...
    '''
    if instances_were_terminated:
        time.sleep(30.0)

    '''
    Now try and delete the actual ASG's and keep trying until SUCCESS!
    '''
    for asg_name in asgs_to_delete:
        asg_to_delete = asgs_to_delete[asg_name]
        asg_successfully_deleted = False

        print "Attempting to delete ASG: " + asg_to_delete.name + ". This could take a few tries as we wait for the instance to terminate."

        while not asg_successfully_deleted:
            try:
                asg_to_delete.delete()
                asg_successfully_deleted = True
            except:
                #Couldn't delete, sleep for 10 seconds and try again..
                print "Couldn't delete asg: " + asg.name + ". trying again."
                time.sleep(10.0)

    all_launch_configs = get_all_launch_configs(asg_conn)

    for lc_name in all_launch_configs:
        if lc_name.startswith('testappname-teststack-Free.form'):
            lcs_to_delete[lc_name] = all_launch_configs[lc_name]
    for lc_name in lcs_to_delete:
        print "Deleting LC: " + lc_name
        lcs_to_delete[lc_name].delete()


if __name__ == "__main__":
    main(sys.argv)
