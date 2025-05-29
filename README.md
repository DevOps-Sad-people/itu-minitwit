# ITU MiniTwit - A DevOps Education Project
ITU MiniTwit is a lightweight Twitter clone developed for the DevOps course at IT University of Copenhagen. This project demonstrates modern software development practices with a focus on DevOps principles, continuous integration/deployment, and infrastructure automation.

The application is built using Ruby with Sinatra, backed by PostgreSQL, and features a complete CI/CD pipeline with automated testing and deployment. The system architecture utilizes Docker containers orchestrated with Docker Compose, with deployments managed through GitHub Actions to Digital Ocean infrastructure.

MiniTwit provides core social media functionality including user registration, authentication, message posting, and following other users. The application exposes both HTML endpoints for browser interaction and JSON API endpoints for programmatic access.

This project serves as a practical example of DevOps best practices including infrastructure as code, monitoring, logging, and automated testing while maintaining a well-documented codebase with thorough deployment instructions.



## TOC
- [Architecture](./docs/architecture.md)  
- [Deployment](./docs/deployment.md)  
- [Development](./docs/development.md)  
- [Monitoring+logging](./docs/monitoring-logging.md)  
- [Testing](./docs/testing.md)  
- [Workflows](./docs/workflows.md)
- [Environment Variables](./environment-variables.md)  


![](https://github.com/DevOps-Sad-people/itu-minitwit/actions/workflows/deploy-to-production.yml/badge.svg)
![](https://github.com/DevOps-Sad-people/itu-minitwit/actions/workflows/deploy-to-staging.yml/badge.svg)

# Architecture

The current achitecture of the minitwit system.
![Project architecture](./images/minitwit_terraform_architecture.drawio.png)
The current deployment flow.
![Deployment flow](./images/deployment_flow.drawio.png)

# Deployment


## Deploy using Vagrant.

We use Vagrant to provision a droplet to Digital Ocean. For this to work, a few configuration steps must be taken. The github workflows refer to the reserved IPs, so after provisioning, you need to assign these IPs to the droplets.

Before starting, you are required to have an [ssh-key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) and a [digital ocean token](https://docs.digitalocean.com/reference/api/create-personal-access-token/), with access to the container registry & droplets. Likewise, you are required to have the PROFESSIONAL plan of container registry at Digital Ocean. Add your SSH key to DO, such that it knows your key.


### PREPARE FOR DEPLOYMENT
1. Add following variables to your bash/zsh environment (Or simply run them)
```bash
export DIGITAL_OCEAN_TOKEN="your-generated-token"
export SSH_KEY_NAME="name-of-your-ssh-key-in-DO" # DO > settings > security > name
export SSH_PRIVATE_KEY_PATH="private-ssh-key-path"
```
2. Add your public SSH key to `remote_files/authorized_keys`
3. Adjust env variables in `.github/workflows/deploy-to-XXXX.yml`
4. Add secrets to Github, to allow Github Actions to operate on Digital Ocean resources. Specifically add a secret `DIGITALOCEAN_ACCESS_TOKEN` and `SSH_KEY`. The access token requires access to the read/write to the container registry. The SSH_KEY is the private key of some private/public key, that must also be included in `remote_files/authorized_keys`. This should preferably be an isolated key, not available on private machines.
5. Install [vagrant](https://developer.hashicorp.com/vagrant/install)
6. Add DO vagrant plugin `vagrant plugin install vagrant-digitalocean`

### COMMANDS:
- `vagrant up` - Spin up instance
- `vagrant destroy` - Destroy current instance
- `doctl compute ssh app-name` - SSH into instance. default app-name is `minitwit`. [Install doctl here](https://docs.digitalocean.com/reference/doctl/how-to/install/)

If you want to run a specific vagrant file, you can specify it by setting the `VAGRANT_VAGRANTFILE` env variable. E.g.:
```bash
VAGRANT_VAGRANTFILE=VagrantfileStaging vagrant up --provider=digital_ocean
```

## Deploy using Docker Swarm.

Instantiate multiple droplets either using the Digital Ocean CLI or their UI. Obtain an SSH access and secure copy all remote_files to each of the servers. The remote_files contains a docker_compose file for both a staging and production environment. Both depends on containers deployed to DO's container registry, using the worksflows in this repo. Run workflows to push containers before continuing. (This step may take a little while, given the configuration required to setup the deployment).

Next you need to find the private IP of the manager machine on it's VPC Network at https://cloud.digitalocean.com/networking/vpc. And you likewise need a token from https://cloud.digitalocean.com/account/api/tokens. The token only needs READ permission to the DO container registry.

You are now ready, and can run the following command on the manager droplet.
Start by initializing the manager, run the following on the manager droplet: `sh /remote_files/scripts/init-manager.sh <manager_vpc_ip> <docker_token>`.

Using the key provided from the script, and the local IP address provided by DO's user interface, run `sh /remote_files/scripts/init-worker.sh <manager_vpc_ip> <manager_token>`

**You now have a stack running successfully!**

If you wish to continue to setup NGINX, you can run the script on the manager node `sh /remote_files/scripts/upgrade-to-ssl.sh example.com 4567`. This requires you have a domain that points to the machine itself.

## Deploy using Terraform

To deploy using terraform, run the terraform bootstrap script:

`cd terraform`
`sh bootstrap.sh`

## Endpoints
`:username` in a route means it is a dynamic route parameter - this means `:username` is placeholder for a real username.
E.g the username `nicra` - the route `/nicra` would show the profile of `nicra`

**Note**:   
You should place route with dynamic route parameters in the buttom of files, because the routes are evaluated from top to bottom.
e.g. /:username would match /login or /logout

### Minitwit endpoints (returns html)
| Endpoint             | Method       | Description                |
|----------------------|------------- |----------------------------|
| `/`                  | `GET`        | Root/Home page. Shows timeline.             |
| `/login`             | `GET, POST`  | User login                 |
| `/register`          | `GET, POST`  | User registration          |
| `/logout`            | `GET`        | User logout                |
| `/public`            | `GET`        | Displays the latest messages of all users.       |
| `/:username/follow`  | `GET`        | Follow a user              |
| `/:username/unfollow`| `GET`        | Unfollow a user            |
| `/add_message`       | `POST`       | Add a new message          |
| `/:username`         | `GET`        | View user profile/messages |


### Api Endpoints (GET returns JSON and POST status code)

| Endpoint             | Method       | Description                |
|----------------------|------------- |----------------------------|
| `/msgs`              | `GET`        | Get public messages        |
| `/msgs/:username`    | `GET, POST`  | GET: Public messages for a specific user. POST: post a new message for a specific username.                 |
| `/fllws/:username`   | `GET, POST`  | GET: Returns a list of users whom the given user follows. POST: Allows a user to follow or unfollow another user                 |
| `/latest`            | `GET`  | Retrieves the latest processed command ID                 |
| `/register`            | `POST`  | Create a new user               |


## Release

Releases are done automatically by Github Actions.  
The release version is determined by the contents of the last commit message, for every push on main (which will be the merge commit).  
- If you include `#major` in the commit message, it will bump the major version for the release.
- If you include `#minor` in the commit message, it will bump the minor version for the release.
- If you include `#patch` in the commit message, it will bump the patch version for the release.
- If you include `#none` in the commit message, **no release will be done**.
- Otherwise, if you don't include any of the above options, the *minor* version will be bumped by default.


## Info
### Upgrade from docker compose to docker stack

We upgraded to use docker compose scripts. 
For the horizontal scaling we had to implement docker stack. 

Docker stack is a way to deploy and manage mulitple docker continers across a Swarm environment - a multi-container application. 

The docker stack deployment features in docker builds on [legacy version of the Compose file format](https://docs.docker.com/reference/compose-file/).

Further there are other differences when using a compose file for a docker stack deployment compared to a docker compose deployment. 

In a docker stack deployment pre-built images are required - where in Docker Compose you can build the images. 

**docker compose vs docker stack fields**

When using `docker stack deploy` some fields in the compose file are ignored:
- `build`
- `container_name`
- `cap_add`
- `depend_on`
- `privileged`

Then some additional fields can be specified when using docker stack
- `deploy` with the subfields
   - `replicas`, `resources`, `placement`, `update_config`
- `mode` (`global` or `replicated`)


The legacy docker compose versioning, the differences in the fields available made it diffucult to transition from `docker compose` to `docker stack deploy`.

# Development

- [Development](#development)
    - [Developing erb files](#developing-erb-files)
  - [Development Workflow](#development-workflow)
    - [Development Environment](#development-environment)
    - [How to run locally](#how-to-run-locally)
    - [Repo settings](#repo-settings)
    - [Ways of Working](#ways-of-working)
  - [Playwright](#playwright)
    - [Setting up](#setting-up)
    - [How to record and generate](#how-to-record-and-generate)
  - [Terraform](#terraform)
    - [Setup](#setup)
    - [Usage](#usage)


## Developing erb files

The `.erb` files are in folder `templates/`

read more about the erb syntax [here](https://www.puppet.com/docs/puppet/5.5/lang_template_erb.html)

The css file is in the `public/stylesheets` folder.

The erb structure and syntax
```erb
<%# Non-printing tag ↓ -%>
<% if @keys_enable -%>
<%# Expression-printing tag ↓ -%>
keys <%= @keys_file %>
<% unless @keys_trusted.empty? -%>
trustedkey <%= @keys_trusted.join(' ') %>
<% end -%>
<% if @keys_requestkey != '' -%>
requestkey <%= @keys_requestkey %>
<% end -%>
<% if @keys_controlkey != '' -%>
controlkey <%= @keys_controlkey %>
<% end -%>

<% end -%>
``` 

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

## Database

## Database

### Migrations

For more information go to [sequel documentation](https://sequel.jeremyevans.net/documentation.html)
We have created a folder `migrations/` that contains the database changes

For development: `manage_migrations_dev.rb` used in `docker-compose.dev.yml`
For production: `manage_migrations.rb`used in `docker-compose.yml`

This creates a migration of the current database, in this way you can see if the migrations have been applied to the database
This should be run inside the docker container (run Interactive Development 1. and then maybe CTRL+C)

```bash
sequel -d <DB_URL> 
```

### Setup
Create and run a PostgreSQL docker container:
`docker run --name minitwit-postgres --network=minitwit -e POSTGRES_PASSWORD=postgres -d -p 5432:5432 postgres`

Restoring from a dump file:
```
docker exec -it minitwit-postgres /bin/bash
psql -U postgres -d minitwit -f minitwit_db.sql

```

Creating a dump file:
`docker exec minitwit-postgres pg_dump -U postgres -F t postgres > db_dump.sql`

### ORM
The Ruby application communicates with the PostgreSQL database through the [Sequel](https://sequel.jeremyevans.net/) ORM, which handles the database connection, manages the connection pool, and provides an abstraction for executing SQL queries and mapping their results to Ruby objects.

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

## Monitoring

Monitoring is implemented using Prometheus + Grafana.

Go to http://localhost:3000/ to see the dashboard.

Config is stored in yaml and json files, under the folder ./grafana.

Currently configured metrics:

- HTTP response count by status codes
- HTTP error response count
- Latency percentiles
- Average latency
- Total registered users

Currently configured alerts:

- Email alerting when 5XX (server-side) error count exceeds the threshold, on the "HTTP error response count" panel

### How to modify dashboard/metrics:

1. Go to the dashboard on the monitoring interface, make changes. You can add, remove or change panels.
2. You cannot save changes from the UI. Export the whole dashboard as json, and overwrite [this](./grafana/predefined-dashboards/minitwit_dashboard.json) file.
3. Restart the grafana docker container.

### How to add new alert rules:

1. Go to the dashboard, select the panel you want to add alerts to.
2. Create and save alert.
3. Export as json (only way to make it permanent). Copy only the relevant alert group under section "groups". 
4. Save it under [this](./grafana/alerting/alert_rules.yaml) file (append it to section "groups").
5. Restart the grafana docker container.

### How to modify alert rules:

1. Go to the dashboard, select the panel, then the existing alert rule.
2. Select "Export with modifications".
3. Make changes, then export as json.
4. Save it under the relevant file, as discussed before.
5. Restart the grafana docker container.

## Logging

Logging is implemented using the ELFK stack (Elasticsearch, Logstash, Filebeat, Kibana).

Go to http://localhost:5601/ to see the kibana UI.

First time startup:
1. Run ```docker compose -f docker-compose.dev.yml up elasticsearch-setup```. This configures the necessary users and roles for Elasticsearch and the stack.
2. Run the stack normally.
3. On the Kibana UI, click on Analytics/Discover to create the initial data view.

The following fields are the most relevant for filtering logs:
- service: the name of the docker service, as defined in the docker compose file.
- level: the logging level (DEBUG, INFO etc.) if applicable. If a log could not be parsed by Logstash, this field is omitted.
- @timestamp

Config files are stored under ./elk.

Logstash filtering logic can be changed in [this](./elk/logstash/pipeline/logstash.conf) file.

# Testing

- [Testing](#testing)
- [UI-Testing](#ui-testing)
  - [Selenium vs Playwright](#selenium-vs-playwright)
  - [Playwright Testing](#playwright-testing)
    - [How to run](#how-to-run)
    - [Create a new test](#create-a-new-test)
- [Simulator Tests](#simulator-tests)

# UI-Testing

## Selenium vs Playwright

**Selenium**

Architecture: 
1. Selenium use a language specific library (e.g C#, Python, Java, Ruby)
1. WebDriver API
1. Browser Drivers - these are executatbles that act as a middle layer between Selenium and the browser. 
   - Recieve HTTP requests from the Selenium client
   - Translate them into native browser commands (click, navigate, input)
1. Browser
   -  Receives commands from the driver.
   - Executes actions (e.g., loading a page, clicking a button).
   - Returns the result/status back through the driver to the client.

History:
Selenium was created in 2004 and is mature and battle-tested. It support a lot of programming languages. It is compatible with all major browsers. It has a huge community, ecosystem and integration. 


**Playwright**

Architecture: 
1. Playwright uses a language specific library (e.g C#, JavaScript, TypeScript, Python, Ruby)
1. Playwright Driver. Unlike the Selenium, Unlike Selenium, no separate browser driver executables are needed.
1. Playwright uses a WebSocket connection rather than the WebDriver API and HTTP. 

Extra features:
- Playwright works natively with Chromium, Firefox, and WebKit (Safari engine) out of the box
- Auto-waiting for elements prevents flaky tests, whereas Selenium often requires explicit waits
- The webSocket stays open for the duration of the test, so everything is sent on one connection. 

This is one reason why Playwright’s execution speeds tend to be faster.
Genreally Playwrigt is easier to setup and use develop tests.

History:  
Playwright is fairly new to the automation scene created in 2020. It is faster than Selenium and has capabilities that Selenium lacks, but it does not yet have as broad a range of support for browsers/languages or community support. It is open source and [backed by Microsoft](https://github.com/microsoft/playwright).


We tried to implement both Selenium and Playwright. For us it was impossible to get the Selenium to work, we had critical problems with the external browser drivers needed for the Selenium framework to work. Playwright did not need external dirvers since built in protocol clients and was easy to setup and use to develop new UI test. 


## Playwright Testing

### How to run
How to run all test locally - this will find the test automatically

```bash
pytest
```

if you want to see the test you can run
```bash
pytest --browser chromium --headed --slowmo 200
```

if you want to only run ONE file

```bash
pytest Playwright/test_signup.py  --browser chrome --headed --slowmo 200
```
### Create a new test
1. Create a new file in the `Playwright` folder with the name `test_<new_test>.py`
1. The file should have functions to test the new functionality
1. The function take in the `Page` class from `playwright.sync_api` 
1. The function should have `page.goto("<url_of_page_to_test>")`
1. Then the rest of the function should test the functionality of the page
1. Read the next section to see how to record a test

# Simulator Tests

The simulator can be found in the folder `simulator/` and contains
- `minitwit_scenario.csv` (data)
- `minitwit_simulator_test.py` (sends request with the data)

The simulator test are run as a part of the testing pipeline/workflow [`test-on-request.yml`](../.github/workflows/test-on-request.yml) . It runs to ensure that the enpoints behave correctly, testing that the endpoints are available and return the correct status codes. 


# Workflows (GitHub Actions)

The workflows are located in the `.github/workflows` folder

## Deployment Workflows 

We have two different deployment workflows, the deployment to production and deployment to staging workflow. 

### Deployment to Production

`deployment-to-production.yml` 

This workflow is triggered on merge to main and deploys the application to the production environment. It builds the Docker images, pushes them to the container registry on DO, and deploys them to the production servers.
It also runs the unit and E2E tests to validate the artifact before deployment.
A tag is created for the release version, which is determined by the contents of the commit messages.

### Deployment to Staging

`deployment-to-staging.yml`   
This workflow is triggered on merge to develo and deploys the application to the production environment. It builds the Docker images, pushes them to the container registry on DO, and deploys them to the staging server.
It also runs the unit and E2E tests to validate the artifact before deployment.


## Testing Workflows

`E2E-on-request.yml`
This workflow is trigged on pull request and runs on deployment workflow. The end to end tests are located in the `Playwright` implemented with Playwright. On how to develop test go to [Testing](testing.md).   

`test-on-request.yml`
The test on request is trigged on a pull request. This workflow contains the unit test and simulator tests.
The simulator test spins up the application and makes request for the endpoints with data from `simulator/minitwit_scenario.csv`


## Generate report Worflow

We have a workflow for generating the report `generate-report.yml`. 
This workflow is trigged on merge to main and generate the `report.pdf` from the markdown files in `report/` folder.
The file `report.pdf` is placed in `report/build/` folder.
 
# Environment Variables

## Database Configuration
- `DB_HOST`: Database host address (default: `db`)
- `DB_PORT`: Database port (default: `5432`)
- `DB_NAME`: Database name (default: `minitwit`)
- `DB_USER`: Database username (default: `postgres`)
- `DB_PASSWORD`: Database user password

## PostgreSQL Configuration
- `POSTGRES_USER`: PostgreSQL username
- `POSTGRES_PASSWORD`: PostgreSQL password
- `POSTGRES_DB`: PostgreSQL database name
- `POSTGRES_DATABASE`: PostgreSQL database name
- `POSTGRES_HOST`: PostgreSQL host address
- `POSTGRES_PORT`: PostgreSQL port

Given multiple applications utilize this postgres instance, and that the naming of the variables has not been aligned, the same database name/post etc. is repeated in multiple variables.

## Backup Configuration
- `SCHEDULE`: Backup frequency (optional, default: `@daily`)
- `BACKUP_KEEP_DAYS`: Number of days to retain backups (optional, default: `7`)
- `PASSPHRASE`: Encryption key for backups (optional)

## S3 Storage Configuration for backup. Requires a S3-compatible target
- `S3_REGION`: S3 region identifier
- `S3_ENDPOINT`: S3 service endpoint URL
- `S3_ACCESS_KEY_ID`: S3 access key ID
- `S3_SECRET_ACCESS_KEY`: S3 secret access key
- `S3_BUCKET`: S3 bucket name
- `S3_PREFIX`: S3 backup directory prefix

## Application Configuration
- `SECRET_KEY`: Application encryption/description key for database passwords
- `SIMULATOR_IP`: Allowed simulator IP addresses (pass * for all)

## Grafana Configuration
- `GF_SECURITY_ADMIN_USER`: Grafana admin username
- `GF_SECURITY_ADMIN_PASSWORD`: Grafana admin password
- `GF_POSTGRES_USERNAME`: Grafana PostgreSQL username
- `GF_POSTGRES_PASSWORD`: Grafana PostgreSQL password
- `GRAFANA_POSTGRES_USERNAME`: Grafana PostgreSQL username
- `GRAFANA_POSTGRES_PASSWORD`: Grafana PostgreSQL password

This database is a different instance from the minitwit database. This is to separate the concern of running an application and monitoring it. Likewise, the database may run on difference virtual machines

### Grafana SMTP
- `GF_SMTP_ENABLED`: Enable SMTP for Grafana
- `GF_SMTP_HOST`: SMTP server address and port
- `GF_SMTP_USER`: SMTP username
- `GF_SMTP_PASSWORD`: SMTP password
- `GF_SMTP_SKIP_VERIFY`: Skip SSL verification
- `GF_SMTP_FROM_NAME`: Sender name for emails
- `GF_SMTP_FROM_ADDRESS`: Sender email address
The email service allows us to send emails to alert for certain activities

## ELK Stack Configuration
- `ELASTIC_VERSION`: Elasticsearch version
- `ELASTIC_USERNAME`: Elasticsearch username
- `ELASTIC_PASSWORD`: Elasticsearch password
- `KIBANA_SYSTEM_USERNAME`: Kibana system username
- `KIBANA_SYSTEM_PASSWORD`: Kibana system password
- `BEATS_SYSTEM_USERNAME`: Beats system username
- `BEATS_SYSTEM_PASSWORD`: Beats system password
- `LOGSTASH_INTERNAL_PASSWORD`: Logstash internal password
- `FILEBEAT_INTERNAL_PASSWORD`: Filebeat internal password
- `METRICBEAT_INTERNAL_PASSWORD`: Metricbeat internal password
- `HEARTBEAT_INTERNAL_PASSWORD`: Heartbeat internal password
- `MONITORING_INTERNAL_PASSWORD`: Monitoring internal password

### Linters
Currently there are 3 linters used for this project, which are the following:
- [Standard Ruby linter](https://github.com/standardrb/standard)
- [ERB linter](https://github.com/Shopify/erb_lint)
- [Dockerfile linter](https://github.com/hadolint/hadolint)


