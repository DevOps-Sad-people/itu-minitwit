docker compose -f docker-compose.yml pull
# docker compose -f docker-compose.yml up -d
docker stack deploy -c docker-compose.yml minitwit