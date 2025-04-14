# Converts the contents of the .env file into docker secrets
bash convert_env_into_secrets.sh

docker compose -f docker-compose.yml pull
# docker compose -f docker-compose.yml up -d
docker stack deploy -c docker-compose.yml minitwit