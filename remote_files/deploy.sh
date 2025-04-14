#!/bin/bash

# Pull images from registry
docker compose -f docker-compose.yml pull

# Interpolate env variables for swarm, then deploy
bash interpolate_compose_file.sh | docker stack deploy -c - minitwit