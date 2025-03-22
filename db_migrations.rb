require 'sequel'

## This is a required extension for Sequel to run migrations
Sequel.extension :migration

def migrate_db(db)
  Sequel::Migrator.run(db, 'migrations')
  puts "Database migrated"
end