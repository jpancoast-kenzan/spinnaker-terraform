#!/bin/bash

available_cloud_providers=(aws)
available_actions=(plan apply destroy)

while  [[ $# > 0 ]]
do
    key="$1"

    case $key in
        -c|--cloud_provider)
        CLOUD_PROVIDER="$2"
        shift
        ;;
        -a|--action)
        ACTION="$2"
        shift
        ;;
        -s|--statepath)
        STATEPATH="$2"
        shift
        ;;
        -l|--log)
        LOG="YES"
        ;;
    esac
    shift
done


SCRIPT_DIR=$(pwd)

CURRENT_DATE=$(date +%Y-%m-%d-%H-%M)


if [ "x$CLOUD_PROVIDER" == "x" ]; then
    echo "usage: $0 -c <cloud provider (aws only for now)> -a <terraform action to perform plan|apply|destroy> -s <terraform state path>(optional, defaults to PWD) -l (optional)"
    exit 1
fi

if [ "x$ACTION" == "x" ]; then
    echo "usage: $0 -c <cloud provider (aws only for now)> -a <terraform action to perform plan|apply|destroy> -s <terraform state path>(optional, defaults to PWD) -l (optional)"
    exit 1
fi

if [ "x$STATEPATH" == "x" ]; then
    #default to PWD
    STATEPATH=$SCRIPT_DIR/$CLOUD_PROVIDER/terraform.tfstate
fi

cp_match=0
for cp in "${available_cloud_providers[@]}"; do
    if [[ $cp = $CLOUD_PROVIDER ]]; then
        cp_match=1
        break
    fi
done

if [[ $cp_match = 0 ]]; then
    echo "$CLOUD_PROVIDER is not a valid cloud provider choice. The choices are:"

    for cp in "${available_cloud_providers[@]}"; do
        echo "    $cp"
    done
fi


action_match=0
for available_action in "${available_actions[@]}"; do
    if [[ $available_action = $ACTION ]]; then
        action_match=1
        break
    fi
done

if [[ $action_match = 0 ]]; then
    echo "$ACTION is not a valid action choice. The choices are:"

    for available_action in "${available_actions[@]}"; do
        echo "    $available_action"
    done
fi


echo "Running on " $CURRENT_DATE


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


if [ "$ACTION" != "destroy" ]; then
	cd $SCRIPT_DIR/$CLOUD_PROVIDER

	echo "Getting/updating required modules"
	terraform get -update


	#
	#	This is looking for a 'kenzan_spinnaker_get_info.py' script, which comes from the module
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

if [ "$ACTION" != "destroy" ] && [ "$LOG" == "YES" ]; then
	#
	#	Where to log the 'apply' and 'plan' output
	#
	LOG_TARGET=/tmp/$CLOUD_PROVIDER.SPINNAKER.$ACTION.$(date +%Y-%m-%d-%H-%M-%S)
	echo "Logging to: $LOG_TARGET"
	terraform $ACTION -no-color -state=$STATEPATH -backup=$STATEPATH.backup > $LOG_TARGET 2>&1
else
	terraform $ACTION -state=$STATEPATH -backup=$STATEPATH.backup
fi