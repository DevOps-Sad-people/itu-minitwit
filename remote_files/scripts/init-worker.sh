# Description: This script is used to initialize a manager node in a cluster.
# It installs Docker, Docker Compose, and the DigitalOcean CLI (doctl).
# It also sets up the firewall rules and authenticates with the DigitalOcean registry.
# Usage: ./init-manager.sh <private_ip> <doctl_token>

if [ -z "$1" ]; then
  echo "Usage: $0 <private_ip> <manager_token>"
  echo "Please provide the private IP of the manager node as an argument."
  echo "You can find the private IP of the manager on it's VPC Network at https://cloud.digitalocean.com/networking/vpc."
  echo "Click the relevant network and then add the private IP address of the manager."
  exit 1
fi

if [ -z "$2" ]; then
  echo "Usage: $0 <private_ip> <manager_token>"
  echo "Please provide the manager token as an argument."
  echo "You can get the manager token by running 'docker swarm join-token worker' on the manager node."
  exit 1
fi

WORKER_IP=$1
TOKEN=$2

sudo apt-get update
sudo apt-get install -y docker.io docker-compose-v2
ufw allow 22/tcp

docker swarm join --token $TOKEN $WORKER_IP:2377