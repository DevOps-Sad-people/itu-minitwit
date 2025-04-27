#!/bin/bash

TAG=${1:-latest} # Default to 'latest' if no tag is provided
TYPE=${2:-staging} # Default to 'dev' if no type is provided

if [ "$TYPE" == "staging" ]; then
  TAG=$TAG docker stack deploy -c docker-compose.staging.yml --with-registry-auth minitwit -d
else
  TAG=$TAG docker stack deploy -c docker-compose.yml --with-registry-auth minitwit -d
fi

