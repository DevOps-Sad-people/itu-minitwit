# Converts the contents of the .env file into docker secrets
bash convert_env_to_secrets.sh

# Deletes all docker configs so we recreate from the compose
docker config ls -q | xargs -r docker config rm

docker compose -f docker-compose.yml pull
# docker compose -f docker-compose.yml up -d
docker stack deploy -c docker-compose.yml minitwit