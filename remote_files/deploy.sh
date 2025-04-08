#!/bin/bash

TAG=${1:-latest} # Default to 'latest' if no tag is provided

# Pull the specific image tag
docker compose -f docker-compose.yml pull

# Deploy the stack with the specified tag
TAG=$TAG docker stack deploy -c docker-compose.yml minitwit