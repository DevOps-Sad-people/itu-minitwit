#####################################################################
# This script is a template for setting up PostgreSQL logical replication
# between a source and target server. It includes instructions for configuring
# the source and target servers, creating users, and setting up replication slots.
# The script also includes commands to create a publication and subscription for
# the replication process.
# The script is not functional as it is missing the actual implementation of
# the replication setup. It serves as a guide for users to follow when setting
# up logical replication in PostgreSQL.
#####################################################################

## SOURCE DATABASE

mkdir -p ~/postgresql-config
nano ~/postgresql-config/pg_hba.conf
# Add the following lines to the end of the file
host    replication     postgres     <replica_db_ip>/32        md5

nano ~/postgresql-config/postgresql.conf
# Add the following lines to the end of the file
wal_level = logical
ALTER SYSTEM SET max_replication_slots = 10
ALTER SYSTEM SET max_wal_senders = 10

# Add volumes to docker-compose.yml
#    volumes:
#      - ~/postgresql-config/pg_hba.conf:/etc/postgresql/pg_hba.conf
#      - ~/postgresql-config/postgresql.conf:/etc/postgresql/postgresql.conf

# Change pw + open ports


docker exec -it [container_name] psql -U postgres

\c minitwit
CREATE PUBLICATION pub_migration FOR TABLE
      public.user,                      
      public.follower,            
      public.message                    
   WITH (publish = 'insert, update, delete');


# restart
docker compose up -d

#### TARGETSERVER

# CP schema.sql to server
docker exec -it $DB_NAME psql -U postgres
SELECT pg_reload_conf();
docker compose up -d

docker cp schema.sql $DB_NAME:/schema.sql

docker exec -it minitwit_db psql -U postgres -d minitwit
CREATE DATABASE minitwit;
\c minitwit
\i /schema.sql

CREATE SUBSCRIPTION sub_migration
   CONNECTION 'host=address_ip port=5432 dbname=minitwit user=postgres password=password'
   PUBLICATION pub_migration
   WITH (
      copy_data = true,
      create_slot = true,  
      enabled = true       
    );

# Check the status of the subscription

SELECT * FROM pg_stat_subscription;
# Check the status of the publication
SELECT * FROM pg_stat_replication;
# Check the status of the replication slot
SELECT * FROM pg_replication_slots;