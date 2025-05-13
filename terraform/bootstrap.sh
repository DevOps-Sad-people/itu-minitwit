#!/bin/bash

set -e

echo -e "\n--> Bootstrapping Minitwit\n"

result=${PWD##*/} 
# check if current directory is terraform
if [ "$result" != "terraform" ]; then
    echo -e "\n--> Please run this script from the terraform directory\n"
    exit 1
fi

# check if ssh-key already exists
if [ -d "ssh_key" ]; then
    echo -e "\n--> SSH key already exists, skipping generation\n"
else
    echo -e "\n--> Generating SSH key\n"
    mkdir ssh_key && ssh-keygen -t rsa -b 4096 -q -N '' -f ./ssh_key/terraform
fi

# check if temp directory already exists
if [ -d "temp" ]; then
    echo -e "\n--> Temp directory already exists, skipping generation\n"
else
    echo -e "\n--> Generating temp directory\n"
    mkdir temp
fi

echo -e "\n--> Loading environment variables from secrets file\n"
source secrets

echo -e "\n--> Checking that environment variables are set\n"
# check that all variables are set
[ -z "$TF_VAR_do_token" ] && echo "TF_VAR_do_token is not set" && exit
[ -z "$SPACE_NAME" ] && echo "SPACE_NAME is not set" && exit
[ -z "$STATE_FILE" ] && echo "STATE_FILE is not set" && exit
[ -z "$AWS_ACCESS_KEY_ID" ] && echo "AWS_ACCESS_KEY_ID is not set" && exit
[ -z "$AWS_SECRET_ACCESS_KEY" ] && echo "AWS_SECRET_ACCESS_KEY is not set" && exit
[ -z "$DIGITAL_OCEAN_KEY" ] && echo "DIGITAL_OCEAN_KEY is not set" && exit

echo -e "\n--> Fetching Environment File from Digital Ocean\n"

aws --endpoint-url https://fra1.digitaloceanspaces.com \
    s3 cp s3://$SPACE_NAME/minitwit/.env ./stack/.env


echo -e "\n--> Initializing terraform\n"
# initialize terraform
terraform init \
    -backend-config "bucket=$SPACE_NAME" \
    -backend-config "key=$STATE_FILE" \
    -backend-config "access_key=$AWS_ACCESS_KEY_ID" \
    -backend-config "secret_key=$AWS_SECRET_ACCESS_KEY"

# check that everything looks good
echo -e "\n--> Validating terraform configuration\n"
terraform validate

# create infrastructure
echo -e "\n--> Creating Infrastructure\n"
terraform apply -auto-approve

# # generate loadbalancer configuration
# echo -e "\n--> Generating loadbalancer configuration\n"
# bash scripts/gen_load_balancer_config.sh

# # scp loadbalancer config to all nodes
# echo -e "\n--> Copying loadbalancer configuration to nodes\n"
# bash scripts/scp_load_balancer_config.sh

# Sign in to container registry
echo -e "\n--> Signing in to container registry\n"

echo \

ssh root@$(terraform output -raw minitwit-swarm-leader-ip-address) \
    -i ssh_key/terraform \
    "export DIGITAL_OCEAN_KEY=${DIGITAL_OCEAN_KEY} && \
    sudo snap install doctl && \
    sudo mkdir -p /root/.config /root/.docker && \
    sudo snap connect doctl:dot-docker && \
    doctl auth init -t \$DIGITAL_OCEAN_KEY && \
    doctl registry login --never-expire"

# Pull images from registry
echo -e "\n--> Pulling images from registry\n"
ssh \
    -o 'StrictHostKeyChecking no' \
    root@$(terraform output -raw minitwit-swarm-leader-ip-address) \
    -i ssh_key/terraform \
    'docker compose -f minitwit_stack.yml pull'

# deploy the stack to the cluster
echo -e "\n--> Deploying the Minitwit stack to the cluster\n"
ssh \
    -o 'StrictHostKeyChecking no' \
    root@$(terraform output -raw minitwit-swarm-leader-ip-address) \
    -i ssh_key/terraform \
    'docker stack deploy minitwit -c minitwit_stack.yml --with-registry-auth'


# #!/bin/bash
# # This script sets up SSL for a domain using Certbot and Nginx on a fresh Ubuntu server
# # Usage: ./upgrade-to-ssl.sh <domain> <port>
# # Example: ./upgrade-to-ssl.sh example.com 3000

# # Write out help message if no arguments are provided
# if [ $# -ne 2 ]; then
#     echo "Usage: $0 <domain> <port>"
#     echo "Example: $0 example.com 3000"
#     exit 1
# fi

# DOMAIN=$1
# PORT=$2

# # Setup CERTBOT for SSL
# # This script is intended to be run on a fresh Ubuntu 20.04 server
# sudo snap install core; sudo snap refresh core
# sudo apt remove certbot
# sudo snap install --classic certbot
# sudo ln -s /snap/bin/certbot /usr/bin/certbot

# # Setup firewall
# ufw enable
# ufw allow OpenSSH

# # Allow existing connections to DOMAIN
# ufw allow $PORT/tcp
# ufw allow $PORT/udp

# # Install Nginx
# sudo apt update
# sudo apt install nginx

# # Setup nginx config
# # /etc/nginx/sites-available/$DOMAIN
# echo "server {
#     listen 80;
#     server_name $DOMAIN www.$DOMAIN;

#     # This location allows Let's Encrypt HTTP verification
#     location /.well-known/acme-challenge/ {
#         root /var/www/html;
#     }

#     location / {
#         proxy_pass http://127.0.0.1:$PORT;
#         proxy_set_header Host \$host;
#         proxy_set_header X-Real-IP \$remote_addr;
#         proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
#     }
# }" | sudo tee /etc/nginx/sites-available/$DOMAIN > /dev/null

# sudo mkdir -p /var/www/html/.well-known/acme-challenge
# sudo chmod -R 755 /var/www/html

# sudo ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/

# sudo nginx -t
# sudo systemctl reload nginx

# sudo ufw allow 'Nginx Full'
# sudo ufw delete allow 'Nginx HTTP'

# echo -e "\n--> Done bootstrapping Minitwit"
# echo -e "--> The dbs will need a moment to initialize, this can take up to a couple of minutes..."
# echo -e "--> Site will be avilable @ http://$(terraform output -raw public_ip):4567"
# echo -e "--> You can check the status of swarm cluster @ http://$(terraform output -raw minitwit-swarm-leader-ip-address):8888"
# echo -e "--> ssh to swarm leader with 'ssh root@\$(terraform output -raw minitwit-swarm-leader-ip-address) -i ssh_key/terraform'"
# echo -e "--> To remove the infrastructure run: bash destroy.sh"
