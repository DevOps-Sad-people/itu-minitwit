DB_NAME=$1

docker exec $DB_NAME pg_dump -U postgres minitwit -f /scheme.sql --schema-only
# Copy the backup file to the host
docker cp $DB_NAME:/scheme.sql ./scheme.sql