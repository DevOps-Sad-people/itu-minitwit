# Environment Variables

## Database Configuration
- `DB_HOST`: Database host address (default: `db`)
- `DB_PORT`: Database port (default: `5432`)
- `DB_NAME`: Database name (default: `minitwit`)
- `DB_USER`: Database username (default: `postgres`)
- `DB_PASSWORD`: Database user password

## PostgreSQL Configuration
- `POSTGRES_USER`: PostgreSQL username
- `POSTGRES_PASSWORD`: PostgreSQL password
- `POSTGRES_DB`: PostgreSQL database name
- `POSTGRES_DATABASE`: PostgreSQL database name
- `POSTGRES_HOST`: PostgreSQL host address
- `POSTGRES_PORT`: PostgreSQL port

Given multiple applications utilize this postgres instance, and that the naming of the variables has not been aligned, the same database name/post etc. is repeated in multiple variables.

## Backup Configuration
- `SCHEDULE`: Backup frequency (optional, default: `@daily`)
- `BACKUP_KEEP_DAYS`: Number of days to retain backups (optional, default: `7`)
- `PASSPHRASE`: Encryption key for backups (optional)

## S3 Storage Configuration for backup. Requires a S3-compatible target
- `S3_REGION`: S3 region identifier
- `S3_ENDPOINT`: S3 service endpoint URL
- `S3_ACCESS_KEY_ID`: S3 access key ID
- `S3_SECRET_ACCESS_KEY`: S3 secret access key
- `S3_BUCKET`: S3 bucket name
- `S3_PREFIX`: S3 backup directory prefix

## Application Configuration
- `SECRET_KEY`: Application encryption/description key for database passwords
- `SIMULATOR_IP`: Allowed simulator IP addresses (pass * for all)

## Grafana Configuration
- `GF_SECURITY_ADMIN_USER`: Grafana admin username
- `GF_SECURITY_ADMIN_PASSWORD`: Grafana admin password
- `GF_POSTGRES_USERNAME`: Grafana PostgreSQL username
- `GF_POSTGRES_PASSWORD`: Grafana PostgreSQL password
- `GRAFANA_POSTGRES_USERNAME`: Grafana PostgreSQL username
- `GRAFANA_POSTGRES_PASSWORD`: Grafana PostgreSQL password

This database is a different instance from the minitwit database. This is to separate the concern of running an application and monitoring it. Likewise, the database may run on difference virtual machines

### Grafana SMTP
- `GF_SMTP_ENABLED`: Enable SMTP for Grafana
- `GF_SMTP_HOST`: SMTP server address and port
- `GF_SMTP_USER`: SMTP username
- `GF_SMTP_PASSWORD`: SMTP password
- `GF_SMTP_SKIP_VERIFY`: Skip SSL verification
- `GF_SMTP_FROM_NAME`: Sender name for emails
- `GF_SMTP_FROM_ADDRESS`: Sender email address
The email service allows us to send emails to alert for certain activities

## ELK Stack Configuration
- `ELASTIC_VERSION`: Elasticsearch version
- `ELASTIC_USERNAME`: Elasticsearch username
- `ELASTIC_PASSWORD`: Elasticsearch password
- `KIBANA_SYSTEM_USERNAME`: Kibana system username
- `KIBANA_SYSTEM_PASSWORD`: Kibana system password
- `BEATS_SYSTEM_USERNAME`: Beats system username
- `BEATS_SYSTEM_PASSWORD`: Beats system password
- `LOGSTASH_INTERNAL_PASSWORD`: Logstash internal password
- `FILEBEAT_INTERNAL_PASSWORD`: Filebeat internal password
- `METRICBEAT_INTERNAL_PASSWORD`: Metricbeat internal password
- `HEARTBEAT_INTERNAL_PASSWORD`: Heartbeat internal password
- `MONITORING_INTERNAL_PASSWORD`: Monitoring internal password