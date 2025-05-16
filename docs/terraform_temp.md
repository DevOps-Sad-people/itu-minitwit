# !!!should be moved when merged with new docs!!!
# TODO
- Read database from backup
- How Setup ssl for domain
- Make sure minitwit_stack is up to date
- Add ssh keys

# Terraform
We use Terraform to manage our production infrastructure. The Terraform code is located in the `terraform` directory.

## Setup
### Install `jq`

Some of the scripts use `jq` which is a cli tool for parsing JSON.

On ubuntu install with:

```bash
sudo apt install -y jq
```

On macOS install with:

```bash
brew install jq
```
On other systems:

Download the binaries here: https://stedolan.github.io/jq/ and put them in a folder included in your system's PATH.

### Install Terraform
Follow the instructions here: https://learn.hashicorp.com/tutorials/terraform/install-cli

### Install AWS CLI
We use the AWS CLI to fetch and upload files to DigitalOcean Spaces Object Storage, which is an S3-compatible object storage service. The AWS CLI is a command-line tool for managing AWS services, but it can also be used with other S3-compatible services like DigitalOcean Spaces Object Storage.

You can install it with the following commands:

On macOS:

```bash
brew install awscli
```
On Ubuntu:

```bash
sudo apt install -y awscli
```

### Add secrets
You need to add a file called `secrets` in the `terraform` directory. You can use the `secrets_template` file as a template.
You can copy it with the following command:

```bash
cp secrets_template secrets
```

This file should contain the following variables:

```bash
export TF_VAR_do_token=<TF_VAR_do_token>
export SPACE_NAME=sadpeople
export STATE_FILE=minitwit/terraform.tfstate
export AWS_ACCESS_KEY_ID=<AWS_ACCESS_KEY_ID>
export AWS_SECRET_ACCESS_KEY=<AWS_SECRET_ACCESS_KEY>
export DIGITAL_OCEAN_KEY=<DIGITAL_OCEAN_KEY>
```

The space name and state file are already set to the values we use in production.


The `TF_VAR_do_token` is used to allow terraform to create resources in your DigitalOcean account. You can create a new token in the DigitalOcean API control panel. Make sure to give it the `read` and `write` permissions.

The `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are your DigitalOcean Spaces Object Storage credentials. You can create them in the DigitalOcean Spaces Object Storage control panel

The `DIGITAL_OCEAN_KEY` is used to sign to the regestry. You can create one in the DigitalOcean API control panel.


## Usage
### Modifying the infrastructure
To modify the infrastructure, you can edit the Terraform files in the `terraform` directory. The main file is `minitwit_swarm_cluster.tf`, which contains the resources and their configurations.

### Creating and updating the infrastructure

We create the `bootstrap.sh` script to bootstrap the infrastructure. This script will create the necessary resources in DigitalOcean and configure them for use with our application.

Make sure to be in the `terraform` directory and run the following command to create the infrastructure:

```bash
./bootstrap.sh
```

### Destroying the infrastructure
To destroy the infrastructure, run the following command in the `terraform` directory:

```bash
./destroy.sh
```
This will prompt you for confirmation before destroying the infrastructure. Type `y` to confirm.
**Note** that this will destroy all resources created by the `bootstrap.sh` script, including the database and any other resources. Make sure to back up any important data before running this command.

