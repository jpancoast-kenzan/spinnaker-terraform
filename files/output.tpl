

Jenkins Public IP (for DNS): ${jenkins_public_ip}
Bastion Public IP (for DNS): ${bastion_public_ip}

Execute the following steps, in this order, to create a tunnel to the spinnaker instance and an example pipeline:

1.	Configure known hosts on the bastion server:
	--- cut ---
	ssh -o IdentitiesOnly=yes -i ${private_key} ${ssh_user}@${bastion_public_ip} 'ssh-keyscan -H ${spinnaker_ip} > ~/.ssh/known_hosts'
	--- end cut ---
		NOTE: THIS needs to be done BEFORE you can run the following tunnel command.

2.	Now, start up a tunnel:
	--- cut ---
	ssh -o IdentitiesOnly=yes -i ${private_key} -L 9000:localhost:9000 -L 8084:localhost:8084 -L 8087:localhost:8087 ${ssh_user}@${bastion_public_ip} 'ssh -o IdentitiesOnly=yes -i /home/${ssh_user}/.ssh/id_rsa -L 9000:localhost:9000 -L 8084:localhost:8084 -L 8087:localhost:8087 -A ${ssh_user}@${spinnaker_ip}'
	--- end cut ---

3.	In a separate window, cd to where you cloned the terraform scripts and run the following command:
    --- cut ---
    cd support ; ./create_application_and_pipeline.py -a testappname -p testappnamepipeline -g ${sg_id} -i ${vpc_id} -v ${vpc_sg_id} -m ${mgmt_sg_id} -n ${vpc_name} -r ${aws_region}
    --- end cut ---

4.	Go to http://${jenkins_public_ip} (This is Jenkins) in your browser and login with the credentials you set in terraform.tfvars.

5.	Go to http://localhost:9000/ in a separate tab in your browser. This is the tunnel to the new Spinnaker instance.

6.	On Jenkins, choose the job "Package_example_app" and "build now"
	NOTE: sometimes the build fails with gradle errors about being unable to download dependencies.

7.	When the Jenkins build is done, go to the spinnaker instance in your browser, select 'appname', and then 'Pipelines'. The pipeline should automatically start after the jenkins job is complete.
	It will bake an AMI, then deploy that AMI.
