# Setup a Controller VM in Azure

> :warning: **UNDER CONSTRUCTION**

[Manual VM Creation](#manual-vm-creation) | [Using Github Actions](#using-github-actions-workflow)

## Manual VM Creation
Create and configure the Controller VM manually.
### Pre-Requisites

- Azure CLI
- Bash
- jq

### Configure
````bash
cp template.create.parameters.json create.parameters.json
vi create.parameters.json
# enter details
 ...
# Note: for better performance, match the zone of the controller with the test infrastructure
````
### Create the VM
````bash
./create.sh
````

Output:
````bash
ls ./state/*.json
cat ./state/loginSSH.sh
````

### Configure VM 
_**Note: these instructions are based on Ubuntu.**_

#### Login

If you have ssh:
````bash
./state/loginSSH.sh
````

Or use a tool to create an ssh session.
Connection info:
````bash
cat ./state/loginSSH.sh
````

#### Python3
````bash
sudo apt update
sudo apt -y upgrade
sudo apt install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update

sudo apt install python3
python3 -V
which python3

sudo apt install python3-pip
pip3 -V
````

#### Ansible & Ansible Solace
````bash
sudo -H python3 -m pip install ansible==2.9.11
pip3 show ansible
ansible --version

sudo -H python3 -m pip install ansible-solace
pip3 show ansible-solace
ansible-doc -l | grep solace

vi ~/.bash_profile
  # add:
  export ANSIBLE_PYTHON_INTERPRETER=/usr/bin/python3

source ~/.bash_profile
env | grep ANS

````
#### Misc Tools
````bash
sudo apt install jq
jq --version

sudo -H python3 -m pip install yq
yq --version

sudo apt install unzip
````

#### Azure CLI
````bash
 curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

 az login

 # use the URL displayed and paste the code to sign in

 export ARM_SUBSCRIPTION_ID={subscription-id}
 export ARM_TENANT_ID={tenant-id}

````

#### Terraform

````bash
mkdir ~/downloads
cd ~/downloads

wget https://releases.hashicorp.com/terraform/0.13.3/terraform_0.13.3_linux_amd64.zip

unzip {terraform zip file}
sudo cp terraform /usr/local/bin
terraform version
````

#### Solace Docker Image

````bash
cd ~/downloads
wget -O solace-pubsub-evaluation-docker.tar.gz https://products.solace.com/download/PUBSUB_DOCKER_EVAL
````

## Using Github Actions Workflow

### Pre-Requisites

- Azure CLI

#### Create the service principal
````bash
export SP_NAME="{unique-service-principal-name}"

# example:
export SP_NAME="solace-ci-controller-sp"
az ad sp create-for-rbac \
  --name $SP_NAME \
  --sdk-auth --role contributor

````


#### Set the Secrets

- **AZURE_CREDENTIALS**={the entire output from service principal command}

- **AZURE_SUBSCRIPTION_ID**={subscription-id}
---
The End.


