require "dotenv/load"

Sequel.migration do
  up do
    run "CREATE ROLE postgres_read;"
    run "GRANT CONNECT ON DATABASE #{ENV.fetch("DB_NAME")} TO postgres_read;"
    run "GRANT USAGE ON SCHEMA public TO postgres_read;"
    run "GRANT SELECT ON ALL TABLES IN SCHEMA public TO postgres_read;"
    run "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO postgres_read;"
    run "CREATE USER #{ENV.fetch("GRAFANA_POSTGRES_USERNAME")} WITH PASSWORD '#{ENV.fetch("GRAFANA_POSTGRES_PASSWORD")}';"
    run "GRANT postgres_read TO #{ENV.fetch("GRAFANA_POSTGRES_USERNAME")};"
  end

  down do
    run "DROP USER #{ENV.fetch("GRAFANA_POSTGRES_USERNAME")};"
    run "DROP OWNED BY postgres_read;"
    run "DROP ROLE postgres_read;"
  end
end
