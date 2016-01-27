#!/bin/bash

available_cloud_providers=(aws gcp)
available_actions=(plan apply destroy)
available_ifconfig_providers=(ipinfo.io/ip ifconfig.co ifconfig.me)

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
    echo "usage: $0 -c <cloud provider> -a <terraform action to perform plan|apply|destroy> -s <terraform state path>(optional, defaults to PWD) -l (optional) -t <terraform vars in this format: \"-var 'variable=value' -var 'variable_2=value_2'\">(optional)"
    exit 1
fi

if [ "x$ACTION" == "x" ]; then
    echo "usage: $0 -c <cloud provider> -a <terraform action to perform plan|apply|destroy> -s <terraform state path>(optional, defaults to PWD) -l (optional) -t <terraform vars in this format: \"-var 'variable=value' -var 'variable_2=value_2'\">(optional)"
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

./support/check_python_prereqs.py $CLOUD_PROVIDER
RETVAL=$?

TF_VERSION=`terraform -version | head -1 | sed -e 's/.*v//'`
TF_FORMATTED_VERSION=`echo $TF_VERSION | sed -e 's/.*v//' -e 's/\.//' -e 's/\.//'`

REQD_TF_VERSION='0.6.9'
REQD_TF_FORMATTED_VERSION=`echo $REQD_TF_VERSION | sed -e 's/\.//' -e 's/\.//'`

if [ "$TF_FORMATTED_VERSION" -ge "$REQD_TF_FORMATTED_VERSION" ] ; then
    echo "Correct TF version."
else
    echo "ERROR: Terraform is not of high enough version. You have $TF_VERSION but you need $REQD_TF_VERSION or above."
    ERROR=1
fi

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

#
#   Determine the public IP of the instance/server/machine this script is running on
#       Checks several services since none of them are reliable. User may have to set this
#           manually
#
if [ "x$LOCAL_IP" == "x" ]; then
    for ifconfig_provider in "${available_ifconfig_providers[@]}"; do
        echo "Checking $ifconfig_provider for local public IP"

        curl_local_ip_command="/usr/bin/curl -s --max-time 20 http://$ifconfig_provider/"

        LOCAL_IP=`$curl_local_ip_command`

        if ! [ "x$LOCAL_IP" == "x" ]; then
            break
        fi
    done
fi

#
#   Absolute last resort check. Separate block because it requires some sed
#
if [ "x$LOCAL_IP" = "x" ]; then
    echo "Checking checkip.dyndns.org for local public IP"
    LOCAL_IP=`curl -s checkip.dyndns.org | sed -e 's/.*Current IP Address: //' -e 's/<.*$//'`
fi

if [ "x$LOCAL_IP" = "x" ]; then
    echo "I couldn't figure out the public IP for this machine. Please set the env variable LOCAL_IP to the correct IP and run this script again."
    exit 1
else
    echo "LOCAL_IP found: $LOCAL_IP"
fi


if [ "$CLOUD_PROVIDER" == "aws" ]; then
    if [ -f "$CLOUD_PROVIDER/spinnaker_variables.tf.json" ] && ! test `find "$CLOUD_PROVIDER/spinnaker_variables.tf.json" -mmin +20`
    then
        echo "$CLOUD_PROVIDER/spinnaker_variables.tf.json exists and is less than 20 minutes old. No need to download it again I don't think."
    else
        echo "Downloading $CLOUD_PROVIDER specific information. If the script stops somewhere in here it's possible $CLOUD_PROVIDER is having API issues."
        COMMAND="./support/"$CLOUD_PROVIDER"_kenzan_spinnaker_get_info.py $CLOUD_PROVIDER"
    
        echo $COMMAND
        eval $COMMAND
    fi
fi


if [ "$CLOUD_PROVIDER" == "gcp" ]; then
    #What's the current username, set ssh_user with it. GCP handles this a bit differently than AWS.
    TFVARS="$TFVARS -var ssh_user=$USER"
fi



cd $SCRIPT_DIR/$CLOUD_PROVIDER

if [ "$ACTION" == "destroy" ]; then
    echo "Deleting any resources created by spinnaker."

    echo "Deleting everything that spinnaker created."
    region=$(terraform show $STATEPATH | grep 'Region: ' | head -n1 | sed -e 's/Region: //' )

    echo "REGION: $region"

    if [ "$CLOUD_PROVIDER" == "aws" ]; then
        vpc_id=$(terraform show $STATEPATH | grep 'VPC_ID: ' | head -n1 | sed -e 's/VPC_ID: //' )
        echo "VPC ID: $vpc_id"

        COMMAND="../support/aws_delete_things.py $region $vpc_id"
    elif [ "$CLOUD_PROVIDER" == "gcp" ]; then
        zone=$(terraform show $STATEPATH | grep 'Zone: ' | head -n1 | sed -e 's/Zone: //' )
        echo "Zone: $zone"

        COMMAND="../support/gcp_delete_things.py $region $zone"
    fi

    echo $COMMAND
    eval $COMMAND
fi


../support/tunnel.sh -s $STATEPATH -a stop

sleep 5

if [ "$ACTION" != "destroy" ] && [ "$LOG" == "YES" ]; then
	#
	#	Where to log the 'apply' and 'plan' output
	#
	LOG_TARGET=/tmp/$CLOUD_PROVIDER.SPINNAKER.$ACTION.$(date +%Y-%m-%d-%H-%M-%S)
	echo "Logging to: $LOG_TARGET"
	COMMAND="terraform $ACTION -no-color -state=$STATEPATH -backup=$STATEPATH.backup -var 'local_ip=$LOCAL_IP/32' -var 'kenzan_statepath=$STATEPATH' $TFVARS > $LOG_TARGET 2>&1"
else
	COMMAND="terraform $ACTION -state=$STATEPATH -backup=$STATEPATH.backup -var 'local_ip=$LOCAL_IP/32' -var 'kenzan_statepath=$STATEPATH' $TFVARS"
fi

echo "Running terraform command:"
echo $COMMAND
echo ""
eval $COMMAND