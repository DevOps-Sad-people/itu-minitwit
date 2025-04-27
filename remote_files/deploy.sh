#!/bin/bash

TAG=${1:-develop} # Default to 'develop' if no tag is provided
TYPE=${2:-staging} # Default to 'staging' if no type is provided

if [ "$TYPE" == "staging" ]; then
  # Pull images from registry
  docker compose -f docker-compose.staging.yml pull

  TAG=$TAG docker stack deploy -c docker-compose.staging.yml --with-registry-auth minitwit -d
else
  # Pull images from registry
  docker compose -f docker-compose.yml pull

  TAG=$TAG docker stack deploy -c docker-compose.yml --with-registry-auth minitwit -d
fi
