# Creating the Spinnaker network in GCP

Bastion: Default instance type: f1-micro (can be changed in terraform.tfvars). All SSH connectivity and tunnels go through this host.

Jenkins & Spinnaker host: Default instance type: n1-highmem-8 (can be changed in terraform.tfvars but this is the smallest recommended size due to Spinnakers memory requirements). Access to this host is tunneled/port forwarded through the bastion because Spinnaker currently has no authorization or authentication available.

Other things the terraform does:
* Creates the necessary firewall rules.
* Creates the test application and pipeline in Spinnaker

## To use:
* Install Pre-Requisites. The scripts will happily complain if the pre-reqs aren't there, but who wants to hear complaining?
  * git
  * Terraform >= 0.6.9
    * Download from https://terraform.io/downloads.html and put it in your $PATH
  * Python Modules:
    * boto >= 2.38.0
    * requests >= 2.8.1
    * json >= 2.0.9
    * docopt >= 0.6.2
  * You may need to install pip. Please consult pip install instructions specific to your OS.
* Look at ./gcp/terraform.tfvars and change anything you think might need changing (region, zone, network_cidr, credentials_file, project, etc.). If these variables are not set you will be prompted for them when you run terraform. These can also be set via the install_spinnaker.sh command line.
  * Required:
    * Set ssh_private_key_location to the filesystem location of the ssh private key associated with your GCP account.
    * Set jenkins_admin_password. Due to a bug in terraform this value must be set here or via the install_spinnaker.sh command line.
  * Optional:
    * Set adm_bastion_incoming_cidrs to a comma separated list of CIDRS that need to access these services. These are only necessary if you will be accessing the services from locations other than the host that is running terraform.
    * Change the value for jenkins_admin_username.
* run the script:
This one is good if you have set all the variables in terraform.tfvars:
```
./install_spinnaker.sh -a apply -c gcp
```
An example of passing variables to terraform via the command line:
```
/install_spinnaker.sh -c gcp -a apply -t "-var jenkins_admin_password=somethingorother -var credentials_file=gcp_credentials_file.json -var project=your-gcp-spinnaker-project-id"
```
-a is the terraform action to run (apply, plan, or destroy)
-c is the cloud provider you're using
There are two optional flags you can pass to the install_spinnaker.sh script
```
-l Tells the script to log the terraform output to a file. Location of file will be printed.
-i <path where to store tf state files>. If you don't want the tfstate files to be stored in the default location ('./')
```

You can also put 'plan' in place of 'apply', and 'terraform plan' will be run, which will show you what terraform would do if you ran apply. It's a good way to test changes to any of the .tf files as most syntax errors will be caught.

... wait 15 minutes or so ...
Pay careful attention to the output at the end, example:
```
Outputs:

   =
Bastion Public IP (for DNS): 104.197.192.50

Region: us-central1
Zone: a
Network: spinnaker-network
STATEPATH: /Users/tempuser/Stuff/code/Work/kenzan/internal/temploc/gcp/terraform.tfstate

Execute the following steps, in this order, to create a tunnel to the spinnaker instance and an example pipeline:

1.  Start up the Spinnaker tunnel:
  --- cut ---
  cd support ; ./tunnel.sh -a start -s /Users/tempuser/Stuff/code/Work/kenzan/internal/temploc/gcp/terraform.tfstate
  --- end cut ---

2.  Go to http://localhost:9090/ (This is Jenkins) in your browser and login with the credentials you set in terraform.tfvars.

3.  Go to http://localhost:9000/ (This is Spinnaker) in a separate tab in your browser. This is the tunnel to the new Spinnaker instance.

4.  On Jenkins, choose the job "TestJob2" and "build now"
  NOTE: sometimes the build fails with gradle errors about being unable to download dependencies. If that happens try building again.

5.  When the Jenkins build is done, go to the spinnaker instance in your browser, select 'appname', and then 'Pipelines'. The pipeline should automatically start after the jenkins job is complete.
  It will bake an image, then deploy that image.

6.  Run the following command and it will give you a URL where you can access the example app that was launched in the previous step (if it was deployed successfully):
  --- cut ---
  cd support ; ./get_lb_url.py gcp testappname-test 7070
  --- end cut ---
  NOTE: it may take a few minutes before the instance is available in the load balancer.
```

To create the Spinnaker tunnel, you need to do run the following command (from the example output above)
```
cd support ; ./tunnel.sh -a start -s /Users/tempuser/Stuff/code/Work/kenzan/internal/temploc/gcp/terraform.tfstate
```

* With the tunnel running you can go to http://localhost:9000/ to access Spinnaker and http://localhost:9090/ to access Jenkins.

With a working pipeline, all you should have to do is go to the 'Package_example_app' job on jenkins and build it. The Spinnaker pipeline will be triggered, an Image baked, and a Server Group deployed with a Load Balancer.

After the pipeline successfully completes run the following from the output above:
```
cd support ; ./get_lb_url.py gcp testappname-test 7070
```
And it will tell you where to point your browser to view the example application you just deployed. It will wait until the Load Balancer is up and accepting traffic so it might take a bit of time.

# Destroying the Spinnaker network
Run this command:
```
./install_spinnaker.sh -a destroy -c gcp
```
Congratulations, your Spinnaker network is now gone!

# If you need to destroy the network manually:
* Terminate all instances in the network that was created.
* Delete any Load Balancers that were created
* Delete the network that was created


## TODO
* Remove unnecessary packages and services from the Bastion host.