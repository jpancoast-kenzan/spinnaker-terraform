#!/usr/bin/env python

import sys
import re
import pprint
import os

try:
    import boto.ec2
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

try:
    import json
except ImportError, e:
    print "Missing json module.  Install with: sudo pip install json"
    print "If you don't have pip, do this first: sudo easy_install pip"
    exit(2)

ubuntu_amazon_image_url = "http://cloud-images.ubuntu.com/locator/ec2/releasesTable"


'''
spinnaker_amazon_image_url = "https://raw.githubusercontent.com/spinnaker/spinnaker.github.io/master/online_docs/quick_ref/ami_table.json"

def parse_spinnaker_amis():
    print "Downloading Spinnaker AMI information..."
    r_spinnaker_images = requests.get(spinnaker_amazon_image_url, timeout=30.0)
    print "Spinnaker AMI information downloaded...\n"
    spinnaker_amis = {}

    ami_info = r_spinnaker_images.json()

    for instance_type in ami_info:
        for region in ami_info[instance_type]:
            spinnaker_amis[
                region + '-' + instance_type.lower()] = ami_info[instance_type][region]

    return spinnaker_amis
'''


def get_aws_info():
    variables_file = "aws/spinnaker_variables.tf.json"

#    spinnaker_amis = parse_spinnaker_amis()

    data_error = False
    region_error = False

    data = {}
    zone_data = {}
    zone_count_data = {}
    ami_data = {}

    data['variable'] = {}

    data['variable']['aws_azs'] = {}
    data['variable']['aws_az_counts'] = {}
    data['variable']['aws_ubuntu_amis'] = {}
#    data['variable']['aws_spinnaker_amis'] = {}

    data['variable']['aws_azs']['description'] = "AWS AZs per region"
    data['variable']['aws_az_counts'][
        'description'] = "AWS AZ counts per region"
    data['variable']['aws_ubuntu_amis']['description'] = "AWS Ubuntu AMIs"
#    data['variable']['aws_spinnaker_amis'][
#        'description'] = "AWS Spinnaker AMIs"

    print "Downloading Ubuntu AMI information..."
    r_ubuntu = requests.get(ubuntu_amazon_image_url, timeout=30.0)
    print "Ubuntu AMI information downloaded...\n"

    print "Downloading Region information..."
    aws_conn = boto.ec2.connect_to_region("us-east-1")

    try:
        regions = aws_conn.get_all_regions()
    except Exception, e:
        print "ERROR: Could not connect to AWS. Check your aws keys."
        exit(1)

    print "Region information downloaded...\n"

    # The URL actually returns invalid json.
    ubuntu_good_json = re.sub("],\n]\n}", ']]}', r_ubuntu.text)

    ubuntu_amis = json.loads(ubuntu_good_json)

    for ami_info in ubuntu_amis['aaData']:
        ami_id = re.search('/.*>(ami-[^<]*)<.*/', ami_info[6]).group(1)
        key = ami_info[0] + "-" + ami_info[1] + "-" + ami_info[3] + "-"

        if re.match('^hvm', ami_info[4]):
            key += "hvm-"
        else:
            key += "pv-"

        key += re.sub('hvm:', '', ami_info[4])

        ami_data[key] = ami_id

    data['variable']['aws_ubuntu_amis']['default'] = ami_data

    for region in regions:
        if region.name == 'sa-east-1':
            print "Skipping region: " + region.name + " as it's really slow."
        else:
            az_string = ''
            zone_count = 0

            print "Parsing zone information for region: " + str(region)

            temp_conn = boto.ec2.connect_to_region(region.name)
            zones = None

            try:
                zones = temp_conn.get_all_zones()
            except Exception, e:
                region_error = True
                print "WARNING: Could not connect to AWS region: " + str(region) + ". Please check your AWS keys. You should be fine to continue if you do not want to use this region for the install."

            if zones is not None:
                for zone in zones:
                    print "\tzone: " + str(zone)
                    az = re.sub(region.name, '', zone.name)
                    az_string = az_string + az + ":"

                    zone_count += 1

                az_string = re.sub(":$", '', az_string)

                zone_data[region.name] = az_string
                zone_count_data[region.name] = str(zone_count)

    data['variable']['aws_azs']['default'] = zone_data
    data['variable']['aws_az_counts']['default'] = zone_count_data
#    data['variable']['aws_spinnaker_amis']['default'] = spinnaker_amis

    '''
    Check to make sure all parts have some data in them
    
    Things to check:
        data['variable']['az_counts']['default'] has more than 1 entry
        data['variable']['azs']['default'] has more than 1 entry
        data['variable']['ubuntu_amis']['default']
        data['variable']['spinnaker_amis']['default']
    '''
    if len(data['variable']['aws_az_counts']['default'].keys()) < 1 or \
            len(data['variable']['aws_azs']['default'].keys()) < 1:

        print "WARNING: NO AZ DATA"
        data_error = True

    if len(data['variable']['aws_ubuntu_amis']['default'].keys()) < 1:
        print "WARNING: NO UBUNTU AMI DATA"
        data_error = True

    '''
    if len(data['variable']['aws_spinnaker_amis']['default'].keys()) < 1:
        print "WARING: NO SPINNAKER AMI DATA"
        data_error = True
    '''
    
    if data_error:
        if os.path.isfile(variables_file):
            # exit status 1 means there was a data error, but the variables
            # file exists, so it's probably OK to continue.
            sys.exit(1)
        else:
            # exit status 2 means there was a data error AND the variables file
            # DOES NOT EXIST, so it is NOT OK to continue
            sys.exit(2)

    f = open(variables_file, 'w')

    f.write(json.dumps(data, indent=4, sort_keys=True))

    f.close()



def main(argv):
    pp = pprint.PrettyPrinter(indent=4)

    if len(sys.argv) != 2:
        print "You need to tell me the cloud provider."
        exit(1)

    cloud_provider = sys.argv[1]

    if cloud_provider == 'aws':
        get_aws_info()
    elif cloud_provider == 'gcp':
        get_gcp_info()
    else:
        print "Invalid Cloud Provider"
        exit(1)

    

if __name__ == "__main__":
    main(sys.argv)
