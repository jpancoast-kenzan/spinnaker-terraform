#!/bin/bash

available_ifconfig_providers=(ipinfo.io/ip ifconfig.co ifconfig.me)



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
#	Absolute last resort check. Separate block because it requires some sed
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