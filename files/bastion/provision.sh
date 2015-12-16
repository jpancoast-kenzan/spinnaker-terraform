#!/bin/sh

mv /tmp/terraform/ssh_config /home/ubuntu/.ssh/config
mv /tmp/terraform/spinnaker-tunnel.sh /home/ubuntu/spinnaker-tunnel.sh

# First put the proper internal zone into ~/.ssh/config
#sed -i.bak -e "s/<INTERNAL_DNS>/${1}/" /home/ubuntu/.ssh/config

chmod a+x /home/ubuntu/spinnaker-tunnel.sh

#rm -rf /tmp/terraform