#!/usr/bin/env python

import sys
import re
import pprint
import os

'''
What we need to do here:
Get the Ubuntu trusty image id (for jenkins)
Get the spinnaker image id (for... wait for it... SPINNAKER!)
'''

def get_gcp_info():
    print "get_gcp_info()"


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