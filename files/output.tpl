

Jenkins Public IP (for DNS): "${jenkins_public_ip}"
Bastion Public IP (for DNS): "${bastion_public_ip}"

Configure known hosts on the bastion server:
	ssh -o IdentitiesOnly=yes -i ${private_key} ${ssh_user}@${bastion_public_ip} 'ssh-keyscan -H ${spinnaker_ip} > ~/.ssh/known_hosts'

Now, start up a tunnel:

SSH CLI command:
	ssh -o IdentitiesOnly=yes -i ${private_key} -L 8080:localhost:8080 -L 8084:localhost:8084 ${ssh_user}@${bastion_public_ip} 'ssh -o IdentitiesOnly=yes -i /home/${ssh_user}/.ssh/id_rsa -L 8080:localhost:80 -L 8084:localhost:8084 -A ${ssh_user}@${spinnaker_ip}'

	- OR - 

You can add the following to your ~/.ssh/config and then 'ssh -f -N spinnaker-tunnel' to setup the tunnel and then to go 'http://localhost:8080/' in your browser.
--- cut ---
Host spinnaker-tunnel
    HostName ${bastion_ip}
    IdentitiesOnly yes
    IdentityFile ${private_key}
    LocalForward 8080 ${spinnaker_ip}:80
    LocalForward 8084 ${spinnaker_ip}:84
    User ${ssh_user}
--- end cut --- 