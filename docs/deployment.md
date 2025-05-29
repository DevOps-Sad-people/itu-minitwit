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



