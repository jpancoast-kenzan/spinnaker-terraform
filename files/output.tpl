

Jenkins Public IP (for DNS): "${jenkins_public_ip}"
Bastion Public IP (for DNS): "${bastion_public_ip}"

Configure known hosts on the bastion server:
	--- cut ---
	ssh -o IdentitiesOnly=yes -i ${private_key} ${ssh_user}@${bastion_public_ip} 'ssh-keyscan -H ${spinnaker_ip} > ~/.ssh/known_hosts'
	--- end cut ---
NOTE: THIS needs to be done BEFORE you can run the following tunnel command.

Now, start up a tunnel:

SSH CLI command:
	--- cut ---
	ssh -o IdentitiesOnly=yes -i ${private_key} -L 9000:localhost:9000 -L 8084:localhost:8084 -L 8087:localhost:8087 ${ssh_user}@${bastion_public_ip} 'ssh -o IdentitiesOnly=yes -i /home/${ssh_user}/.ssh/id_rsa -L 9000:localhost:9000 -L 8084:localhost:8084 -L 8087:localhost:8087 -A ${ssh_user}@${spinnaker_ip}'
	--- end cut ---

To create an example pipeline:
    --- cut ---
    cd support ; ./create_application_and_pipeline.py -a appname -p appnamepipeline -g ${sg_id} -v ${vpc_sg_id} -m ${mgmt_sg_id}
    --- end cut ---


    