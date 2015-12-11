#!/bin/bash

available_cloud_providers=(aws)
available_actions=(plan apply destroy)

iam_roles_to_check_for=(base_iam_role jenkins_role properties_and_logging_role spinnaker_role)
iam_profiles_to_check_for=(jenkins_profile spinnaker_profile properties_and_logging_profile)
keypairs_to_check_for=(my-aws-account-keypair)
subnet_tags_to_check_for=

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
        -t|--tfvars)
        TFVARS="$2"
        ;;
    esac
    shift
done


SCRIPT_DIR=$(pwd)

CURRENT_DATE=$(date +%Y-%m-%d-%H-%M)


if [ "x$CLOUD_PROVIDER" == "x" ]; then
    echo "usage: $0 -c <cloud provider (aws only for now)> -a <terraform action to perform plan|apply|destroy> -s <terraform state path>(optional, defaults to PWD) -l (optional) -t <terraform vars in this format: \"-var 'variable=value' -var 'variable_2=value_2'\">(optional)"
    exit 1
fi

if [ "x$ACTION" == "x" ]; then
    echo "usage: $0 -c <cloud provider (aws only for now)> -a <terraform action to perform plan|apply|destroy> -s <terraform state path>(optional, defaults to PWD) -l (optional) -t <terraform vars in this format: \"-var 'variable=value' -var 'variable_2=value_2'\">(optional)"
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

#Check the version of terraform... >= 0.6.8

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
#Check to see if any of the iam roles exist
#Check to see if the keypair already exists.
#Check to see if the iam profiles exist.
#Check to make sure none of the subnets with tags already exist.
#   Maybe put all these checks in check_prereqs.py, which is a renamed check_python_prereqs.py
echo


if [ -f "$CLOUD_PROVIDER/spinnaker_variables.tf.json" ] && ! test `find "$CLOUD_PROVIDER/spinnaker_variables.tf.json" -mmin +20`
then
    echo "$CLOUD_PROVIDER/spinnaker_variables.tf.json exists and is less than 20 minutes old. No need to download it again I don't think."
else
    echo "Downloading OS Image, region, and AZ information"
    ./support/kenzan_spinnaker_get_info.py $CLOUD_PROVIDER
fi


cd $SCRIPT_DIR/$CLOUD_PROVIDER

if [ "$ACTION" != "destroy" ] && [ "$LOG" == "YES" ]; then
	#
	#	Where to log the 'apply' and 'plan' output
	#
	LOG_TARGET=/tmp/$CLOUD_PROVIDER.SPINNAKER.$ACTION.$(date +%Y-%m-%d-%H-%M-%S)
	echo "Logging to: $LOG_TARGET"
	COMMAND="terraform $ACTION -no-color -state=$STATEPATH -backup=$STATEPATH.backup $TFVARS > $LOG_TARGET 2>&1"
else
	COMMAND="terraform $ACTION -state=$STATEPATH -backup=$STATEPATH.backup $TFVARS"
fi

eval $COMMAND