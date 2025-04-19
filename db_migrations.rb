require "sequel"

## This is a required extension for Sequel to run migrations
Sequel.extension :migration

def migrate_db(db)
  # Check if the database is already migrated
  if db.tables.include?(:follower) && db.tables.include?(:message) && db.tables.include?(:user)
    Sequel::Migrator.run(db, "migrations", current: 1)
    return
  end
  Sequel::Migrator.run(db, "migrations")
  puts "Database migrated"
end
