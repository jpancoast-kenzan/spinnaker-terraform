#!/usr/bin/env python


import yaml
import sys
import pprint


def load_yaml(file_name):
    try:
        with open(file_name) as f:
            data = yaml.load(f)
    except:
        print "Couldn't load " + file_name + ", bad Yaml?"
        exit(2)

    return data


def write_yaml(data, file_name):
    with open(file_name, 'w') as yaml_file:
        yaml_file.write(yaml.dump(
            data, default_flow_style=False, default_style=None, explicit_start=False))


def main(argv):
    pp = pprint.PrettyPrinter(indent=4)

    if len(sys.argv) < 3:
        print "You must provide at least two arguments. The first argument should be the location of the yaml file. The second (and following arguments) shoudl be the things to change. For example:"
        print "\n\t" + sys.argv[0] + " ../testing/spinnaker-local.yml services:jenkins:defaultMaster:username:admin services:jenkins:defaultMaster:password:blah123"
        print "\n\t Will set the services:jenkins:defaultMaster:username to admin, and services:jenkins:defaultMaster:password to blah123"
        exit()

    file_name = sys.argv[1]
    stuff_to_set = sys.argv[2:]

    config_data = load_yaml(file_name)

    for arg in stuff_to_set:
        things = arg.split(':')

        keys = things[:len(things) - 1]
        value = things[len(things) - 1]

        temp_string = 'config_data'

        for key in keys:
            temp_string += '[\'' + key + '\']'

        temp_string += ' = \'' + value + '\''

        print temp_string
        exec(temp_string)

    write_yaml(config_data, file_name)

if __name__ == "__main__":
    main(sys.argv)
