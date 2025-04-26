# Description: This script is used to initialize a manager node in a cluster.
# It installs Docker, Docker Compose, and the DigitalOcean CLI (doctl).
# It also sets up the firewall rules and authenticates with the DigitalOcean registry.
# Usage: ./init-manager.sh <private_ip> <doctl_token>

if [ -z "$1" ]; then
  echo "Usage: $0 <private_ip> <doctl_token>"
  echo "Please provide a private IP address as an argument."
  echo "You can find the private IP of this machine on it's VPC Network at https://cloud.digitalocean.com/networking/vpc."
  echo "Click the relevant Network and then add the private IP address of this machine."
  exit 1
fi

PRIVATE_IP=$1

if [ -z "$2" ]; then
  echo "Usage: $0 <private_ip> <doctl_token>"
  echo "Please provide a DigitalOcean API token as an argument."
  echo "Get a token from https://cloud.digitalocean.com/account/api/tokens. You only need read permissions to the container registry."
  exit 1
fi

TOKEN=$2


sudo apt-get update
sudo apt-get install -y docker.io docker-compose-v2
sudo mkdir -p /root/.config /root/.docker
sudo snap install doctl
sudo snap connect doctl:dot-docker
doctl auth init -t $TOKEN # Get a token from https://cloud.digitalocean.com/account/api/tokens. You only need read permissions to the container registry.
doctl registry login --never-expire --read-only=true
ufw allow 4567
ufw allow 22/tcp
ufw allow 2376/tcp &&ufw allow 2377/tcp && ufw allow 7946/tcp && ufw allow 7946/udp &&ufw allow 4789/udp && ufw reload && ufw --force  enable &&systemctl restart docker
systemctl daemon-reload

## Setup docker swarm
docker swarm init --advertise-addr $PRIVATE_IP