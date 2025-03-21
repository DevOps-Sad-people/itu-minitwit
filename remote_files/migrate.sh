## THIS FILE REQUIRES
# - THE NON-ORM VERSION RUNNING + THE EXISTING DATABASE TO BE RUNNING
# - THE NEW ORM VERSION TO BE AVAILABLE AT DO CONTAINER HUB

# Dump database
docker exec minitwit_db pg_dump -U postgres --inserts minitwit > dump.sql

# Modify the dump file to new setup (Insert users first, then everything else)
awk '/Data for Name: user; /,/Name: message_message_id_seq; Type:/' dump.sql > insert.sql
awk '/Data for Name: follower; /,/Data for Name: user;/' dump.sql >> insert.sql

# Stop and setup new containers
docker compose -f docker-compose.yml pull
docker compose down -v
docker compose -f docker-compose.yml up -d

# wait for the database to be ready
while ! docker exec minitwit_db pg_isready -U postgres; do
  sleep 1
done

# Insert the data into the database
docker exec -i minitwit_db psql -U postgres -d minitwit < insert.sql