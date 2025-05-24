# Deployment


## Deploy using Vagrant.

Before instantiating the virtual machine, you need to setup a DigitalOcean account, and obtain a secret key, which is allows to instantiate droplets (Virtual machine). Once this is done, setup the `.env` file and run `vagrant up` to create and provision the VM.

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




