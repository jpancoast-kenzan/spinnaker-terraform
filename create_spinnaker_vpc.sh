#!/bin/bash

if [ "x$1" = "x" ]; then
	echo "usage: $0 <cloud provider (aws only for now)> <plan|apply>"
	exit 1
fi

if [ "x$2" = "x" ]; then
	echo "usage: $0 <cloud provider (aws only for now)> <plan|apply>"
	exit 1
fi


CLOUD_PROVIDER=$1
ACTION=$2


cd $CLOUD_PROVIDER

terraform $ACTION