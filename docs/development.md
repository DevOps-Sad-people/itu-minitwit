# Development

- [Development](#development)
  - [Development Workflow](#development-workflow)
    - [Development Environment](#development-environment)
    - [How to run locally](#how-to-run-locally)
    - [Repo settings](#repo-settings)
    - [Ways of Working](#ways-of-working)
  - [Playwright](#playwright)
    - [Setting up](#setting-up)
    - [How to record and generate](#how-to-record-and-generate)

## Development Workflow

### Development Environment

When developing new features you branch off `develop` then implement the changes and test them **locally** via the local docker development environment `docker-compose.dev.yml`. Then changes are pushed to a remote branch so another person can continue working on the changes. When the feature/tasks is completed a pull request is created. When the changes are approved they merge into `develop` and trigger a new deployment to the staging environment. If the changes work in the staging environment a pull request from `develop` into `main` can be created. Once the pull request is approved a new release and deployment to production is triggered.   

### How to run locally

To start up all docker services:

`docker compose -f docker-compose.dev.yml up -d`

After this, the minitwit application will be avaible at http://localhost:4567/.

To run a specific service:

`docker compose -f docker-compose.dev.yml up <service_name> -d`

To run the tests:

`docker compose -f docker-compose.testing.yml up --abort-on-container-exit --exit-code-from test`

To stop and delete running containers:

`docker compose -f docker-compose.dev.yml down`

To stop and delete a specific container:

`docker compose -f docker-compose.dev.yml down <service_name>`

To clean up volumes afterwards: (***WARNING:*** deletes all persisted project data)

`docker compose -f docker-compose.dev.yml down --volumes`

### Repo settings

We have setup branch protection to merge into `main` and `develop` 
1. Merge changes through pull request
1. At least one developer has to approve the changes
1. Workflows and test have to pass LINK TO TESTS

This ensures that all changes to the protected branches have been approved and tested.  


### Ways of Working 


Implementing new features

We met up every friday to first present what we each had worked on the last weeks. If one of us had problems or question we would discuss them here. Then plan how to implement the next weeks features.   

We typically worked in three teams
1. Nicolai
1. Gábor and Zalán
1. Sebastian and Nicklas

## Playwright

### Setting up

You can download a VS Code extension "Playwright Test for VSCode" to help with the test.

1. Install python requirements

```bash
pip install -r requirements.txt
```

2. Install Playwright  
If you are having problems with the installation of playwright you can try to install it manually.
 
```bash
pip install playwright
```

3. Install the browsers  
Once you have install playwright you have to install the browsers if you want to run playwright locally 

```bash
playwright install
```

### How to record and generate

You can start the application with the following command
```bash
docker compose -f docker-compose.dev.yml run --rm --service-ports web bash
```



Open a new terminal and enter the following to record a new test:
```bash
playwright codegen http://localhost:4567/public
```

Then you can use the recorder tool to create the test and copy it to the python file `test_<new_test>.py` and function you have created.


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

