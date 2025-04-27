DB_NAME=$1

docker exec $DB_NAME pg_dump -U postgres -F c minitwit -f /backup.dump
# Copy the backup file to the host
docker cp $DB_NAME:/backup.dump ./backup.dump