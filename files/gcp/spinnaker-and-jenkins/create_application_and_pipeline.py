#!/usr/bin/env python

VERSION = '0.1'
SPINNAKER_HOST = 'localhost'
SPINNAKER_PORT = '9000'
GATE_PORT = '8084'

import sys
import os
import re
import pprint

from spinnaker import spinnaker

try:
    import json
except ImportError, e:
    print "Missing json module. Install with: sudo pip install json"
    print "If you don't have pip, do this first: sudo easy_install pip"
    exit(2)

try:
    from docopt import docopt
except ImportError, e:
    print "Missing docopt module.  Install with: sudo pip install docopt"
    print "If you don't have pip, do this first: sudo easy_install pip"
    exit(2)


def main(argv):
    print "THIS IS THE PYTHON SCRIPT YO"

if __name__ == "__main__":
    main(sys.argv)