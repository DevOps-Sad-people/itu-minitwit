require 'sequel'

## This is a required extension for Sequel to run migrations
Sequel.extension :migration

DB_URL = "postgres://#{ENV.fetch('DB_USER')}:#{ENV.fetch('DB_PASSWORD')}@#{ENV.fetch('DB_HOST')}:#{ENV.fetch('DB_PORT')}/#{ENV.fetch('DB_NAME')}"

# print out the connection string
puts "#{DB_URL}"

DB = Sequel.connect(DB_URL)

# Run all migrations but first one
# We skip the first because this is already applied with the schema.sql
# schema.sql == 001_create_user_table.rb - they are the same
Sequel::Migrator.run(DB, 'migrations', current: 1)