#!/bin/sh


mv /tmp/terraform/ssh_config /home/${1}/.ssh/config
mv /tmp/terraform/spinnaker-tunnel.sh /home/${1}/spinnaker-tunnel.sh

# First put the proper internal zone into ~/.ssh/config
#sed -i.bak -e "s/<INTERNAL_DNS>/${2}/" /home/${1}/.ssh/config

chmod a+x /home/${1}/spinnaker-tunnel.sh

#rm -rf /tmp/terraform