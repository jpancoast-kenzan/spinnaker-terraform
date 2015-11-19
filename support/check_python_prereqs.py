#!/usr/bin/env python

import sys
import imp


def main(argv):
    reqd_module_names = ['boto', 'requests', 'json', 'docopt']

    ret_val = 0

    for module_name in reqd_module_names:
        try:
            imp.find_module(module_name)
        except ImportError:
            print "ERROR: Could not import required python module '" + module_name + "'. Please install it with pip."
            ret_val = 1

    sys.exit(ret_val)


if __name__ == "__main__":
    main(sys.argv)
