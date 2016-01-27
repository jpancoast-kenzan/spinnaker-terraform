#!/usr/bin/env python

import sys
import imp
import re


def main(argv):
    cloud_provider = sys.argv[1]

    reqd_module_names_and_versions = {}
    reqd_module_names_and_versions['requests'] = '2.2.1'
    reqd_module_names_and_versions['json'] = '2.0.9'
    reqd_module_names_and_versions['docopt'] = '0.6.2'

    if cloud_provider.lower() == 'aws':
        reqd_module_names_and_versions['boto'] = '2.38.0'
    #elif cloud_provider.lower() == 'gcp':
    #    reqd_module_names_and_versions['libcloud'] = '0.20.0'

    ret_val = 0

    for module_name in reqd_module_names_and_versions:
        try:
            __import__(module_name)

            installed_version = str(__import__(module_name).__version__)

            installed_version_formatted = re.sub(
                "\.", '', str(__import__(module_name).__version__))
            reqd_version = re.sub(
                "\.", '', reqd_module_names_and_versions[module_name])

            if installed_version_formatted < reqd_version:
                print "ERROR: Module " + module_name + " is not of high enough version. You need: v" + reqd_module_names_and_versions[module_name] + ", you have: " + installed_version
                ret_val = 1

        except ImportError:
            print "ERROR: Could not import required python module '" + module_name + "'. Please install it with pip."
            ret_val = 1

    sys.exit(ret_val)


if __name__ == "__main__":
    main(sys.argv)
