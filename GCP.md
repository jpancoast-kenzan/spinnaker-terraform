# Creating the Spinnaker network in GCP

Bastion: Default instance type: f1-micro (can be changed in terraform.tfvars). All SSH connectivity and tunnels go through this host.

Jenkins & Spinnaker host: Default instance type: n1-highmem-8 (can be changed in terraform.tfvars but this is the smallest recommended size due to Spinnakers memory requirements). Access to this host is tunneled/port forwarded through the bastion because it currently has no authorization or authentication available.

Other things the terraform does:
* Creates the necessary firewall rules.
* Creates the test application and pipeline in Spinnaker

## To use:
* Install Pre-Requisites. The scripts will happily complain if the pre-reqs aren't there, but who wants to hear complaining?
  * git
  * Terraform >= 0.6.8 
    * Download from https://terraform.io/downloads.html and put it in your $PATH
  * Python Modules:
    * boto >= 2.38.0
    * requests >= 2.8.1
    * json >= 2.0.9
    * docopt >= 0.6.2
  * You may need to install pip. Please consult pip install instructions specific to your OS.
* generate an ssh key. This should not be your default ssh key.
* Look at ./aws/terraform.tfvars and change anything you think might need changing (region, zone, network_cidr, credentials_file, and project). If these variables are not set you will be prompted for them when you run terraform. These can also be set via the install_spinnaker.sh command line.
  * Required:
    * Set ssh_private_key_location to the filesystem location of the ssh private key you created.
    * Set jenkins_admin_password. Due to a bug in terraform this value must be set here or via the install_spinnaker.sh command line.
  * Optional:
    * Set adm_bastion_incoming_cidrs to a comma separated list of CIDRS that need to access these services. These are only necessary if you will be accessing the services from locations other than the host that is running terraform.
    * Change the value for jenkins_admin_username.
* run the script:
This one is good if you have set all the variables in terraform.tfvars
```
./install_spinnaker.sh -a apply -c gcp
```
An example of passing variables to terraform via the command line:
```
/install_spinnaker.sh -c gcp -a apply -t "-var jenkins_admin_password=somethingorother -var credentials_file=gcp_credentials_file.json -var project=your-gcp-spinnaker-project-id"
```