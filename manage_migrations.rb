require 'sequel'

## This is a required extension for Sequel to run migrations
Sequel.extension :migration

DB_URL = "postgres://#{ENV.fetch('DB_USER')}:#{ENV.fetch('DB_PASSWORD')}@#{ENV.fetch('DB_HOST')}:#{ENV.fetch('DB_PORT')}/#{ENV.fetch('DB_NAME')}"

# print out the connection string
puts "#{DB_URL}"

DB = Sequel.connect(DB_URL)

Sequel::Migrator.run(DB, 'migrations')