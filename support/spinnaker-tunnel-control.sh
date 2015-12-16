#!/bin/bash

socket=$HOME/.ssh/spinnaker-tunnel.ctl

if [ "$1" == "start" ]; then
  if [ ! \( -e ${socket} \) ]; then
    echo "Starting Local tunnel to Spinnaker..."
    ssh -F /tmp/spinnaker_local_ssh_config_for_tunneling -f -N spinnaker-start && echo "Done."
  else
    echo "Tunnel to Spinnaker running."
  fi
fi

if [ "$1" == "stop" ]; then
  if [ \( -e ${socket} \) ]; then
    echo "Stopping Local tunnel to Spinnaker..."
    ssh -F /tmp/spinnaker_local_ssh_config_for_tunneling -O "exit" spinnaker-stop && echo "Done."
  else
    echo "Tunnel to Spinnaker stopped."
  fi
fi