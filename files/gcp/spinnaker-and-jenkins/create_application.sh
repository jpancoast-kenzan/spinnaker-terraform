#!/bin/sh


cd /tmp/terraform/
chmod a+x create_application_and_pipeline.py

/tmp/terraform/create_application_and_pipeline.py -a testappname -p testappnamepipeline -r $1 -z $2 -n $3 -g $4
