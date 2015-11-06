#!/bin/bash

if [ "x$1" == "x" ]; then
	echo "usage: $0 <cloud provider (aws only for now)> <plan|apply|destroy> <log (optional)>" 
	exit 1
fi

if [ "x$2" == "x" ]; then
	echo "usage: $0 <cloud provider (aws only for now)> <plan|apply|destroy> <log (optional)>" 
	exit 1
fi


echo "Checking for pre-requisites"
echo

ERROR=0

for required_bin in git terraform
do
	blah=$(which $required_bin)
	RETVAL=$?
	
	if [ "$RETVAL" != "0" ]; then
		ERROR=1
		echo "ERROR: I could not find a required binary: $required_bin, please install it."
	fi
done

./support/check_python_prereqs.py
RETVAL=$?

if [ "$RETVAL" != "0" ]; then
	echo
	echo 'ERROR: I could not import some or all of the required python modules'
	ERROR=1
fi

if [ "$ERROR" == "1" ]; then
	exit
fi

echo "... All pre-reqs found ..."

echo "here is where we could do some checks to make sure the environment is clean and ready to accept awesomeness"
echo


CLOUD_PROVIDER=$1
ACTION=$2

SCRIPT_DIR=$(pwd)

CURRENT_DATE=$(date +%Y-%m-%d-%H-%M)
echo "Running on " $CURRENT_DATE



if [ "$ACTION" != "destroy" ]; then
	cd $SCRIPT_DIR/$CLOUD_PROVIDER

	echo "Getting/updating required modules"
	terraform get -update


	#
	#	This is looking for a 'kenzan_spinnaker_get_info.py' script, which comes from the module
	#	
	#	TODO: if this fails, do not continue
	#
	for makefile in $(find .terraform/modules -name kenzan_spinnaker_get_info.py -print)
	do
		cd $SCRIPT_DIR/$CLOUD_PROVIDER

		mkfiledir=$(echo $makefile | sed -e 's/kenzan_spinnaker_get_info.py//')

		cd $mkfiledir
		./kenzan_spinnaker_get_info.py

		RETVAL=$?

		if [ "$RETVAL" == "1" ]; then
			echo "WARNING: could not download some information, but it is probably OK to continue."
			echo
		elif [ "$RETVAL" == "2" ] ; then
			echo "ERROR: could not download some information, and it is NOT OK to continue as no previous variables.tf.json file exists."
			exit
		fi
	done
fi

cd $SCRIPT_DIR/$CLOUD_PROVIDER

if [ "$ACTION" != "destroy" ] && [ "$3" == "log" ]; then
	#
	#	Where to log the 'apply' and 'plan' output
	#
	LOG_TARGET=/tmp/$CLOUD_PROVIDER.SPINNAKER.$ACTION.$(date +%Y-%m-%d-%H-%M-%S)
	echo "Logging to: $LOG_TARGET"
	terraform $ACTION > $LOG_TARGET 2>&1
else
	terraform $ACTION
fi