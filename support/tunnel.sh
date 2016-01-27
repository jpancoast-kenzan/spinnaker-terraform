#!/bin/bash


SCRIPT_DIR=$(pwd)


while  [[ $# > 0 ]]
do
    key="$1"

    case $key in
        -s|--statepath)
        STATEPATH="$2"
        shift
        ;;
        -a|--action)
		ACTION="$2"
		shift
		;;
    esac
    shift
done

if [ "x$STATEPATH" == "x" ]; then
    echo "usage: $0 -s <path to terraform state file> -a <start|stop>"
    exit 1
fi

if [ "x$ACTION" == "x" ]; then
    echo "usage: $0 -s <path to terraform state file> -a <start|stop>"
    exit 1
fi

ssh_user=$(terraform show $STATEPATH | grep 'vars.ssh_user = ' | head -n1 | sed -e 's/.*vars.ssh_user\ \= //')
private_key_location=$(terraform show $STATEPATH | grep 'vars.private_key = ' | head -n1 | sed -e 's/.*vars.private_key\ \= //')
bastion_public_ip=$(terraform show $STATEPATH | grep 'vars.bastion_ip = ' | head -n1 | sed -e 's/.*vars.bastion_ip\ \= //')

echo "--- using vars ---"
echo "SSH USER: $ssh_user"
echo "PRIVATE KEY LOCATION: $private_key_location"
echo "BASTION PUBLIC IP: $bastion_public_ip"
echo "--- end using vars ---"

escaped_private_key_location=$private_key_location

escaped_private_key_location=$(echo "$escaped_private_key_location" | sed 's/^\~/\\\~/g' | sed 's/\./\\\./g' | sed 's/\//\\\//g') #This was fun.

if [ "$ACTION" == "start" ]; then
    cp $SCRIPT_DIR/local_ssh_config /tmp/spinnaker_local_ssh_config_for_tunneling

    sed -i.bak -e "s/<BASTION_IP>/$bastion_public_ip/" /tmp/spinnaker_local_ssh_config_for_tunneling
    sed -i.bak -e "s/<SSH_PRIVATE_KEY>/$escaped_private_key_location/" /tmp/spinnaker_local_ssh_config_for_tunneling
else
    if [ -e "/tmp/spinnaker_local_ssh_config_for_tunneling" ]; then
        echo "Local ssh tunneling config exists."
    else
        echo "WARNING Local ssh tunneling config does not exist. This is not a major problem and we are OK to continue."
    fi
fi

if [ "$ACTION" == "start" ]; then
    echo "Starting all the things!"

	REMOTE_TUNNEL_COMMAND="ssh -f -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -i $private_key_location $ssh_user@$bastion_public_ip '/home/$ssh_user/spinnaker-tunnel.sh start'"
	LOCAL_TUNNEL_COMMAND="$SCRIPT_DIR/../support/spinnaker-tunnel-control.sh start"
elif [ "$ACTION" == "stop" ]; then
	echo "Stopping all the things!"

    REMOTE_TUNNEL_COMMAND="ssh -f -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -i $private_key_location $ssh_user@$bastion_public_ip '/home/$ssh_user/spinnaker-tunnel.sh stop'"
    LOCAL_TUNNEL_COMMAND="$SCRIPT_DIR/../support/spinnaker-tunnel-control.sh stop"
else
	echo "Invalid Action: $ACTION"
fi

eval $REMOTE_TUNNEL_COMMAND && $LOCAL_TUNNEL_COMMAND