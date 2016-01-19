#!/bin/sh


cd /tmp/terraform/
chmod a+x create_application_and_pipeline.py

/tmp/terraform/create_application_and_pipeline.py 
#-a testappname -p testappnamepipeline -r $1 -i $2 -o $3 -n $4 -g $5 -v $6 -m $7