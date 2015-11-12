

Jenkins Public IP (for DNS): "${jenkins_public_ip}"
Bastion Public IP (for DNS): "${bastion_public_ip}"

Configure known hosts on the bastion server:
	ssh -o IdentitiesOnly=yes -i ${private_key} ${ssh_user}@${bastion_public_ip} 'ssh-keyscan -H ${spinnaker_ip} > ~/.ssh/known_hosts'
NOTE: THIS needs to be done BEFORE you can run the following tunnel command.

Now, start up a tunnel:

SSH CLI command:
	--- cut ---
	ssh -o IdentitiesOnly=yes -i ${private_key} -L 8080:localhost:8080 -L 8084:localhost:8084 ${ssh_user}@${bastion_public_ip} 'ssh -o IdentitiesOnly=yes -i /home/${ssh_user}/.ssh/id_rsa -L 8080:localhost:80 -L 8084:localhost:8084 -A ${ssh_user}@${spinnaker_ip}'
	--- end cut ---
