# !!!should be moved when merged with new docs!!!
# TODO
- Read database from backup
- Setup ssl for domain
- Make sure minitwit_stack is up to date
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
TODO

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

