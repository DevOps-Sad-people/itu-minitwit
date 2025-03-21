require "rack/test"
require "rspec"
require "tempfile"
require "pg"
require_relative "../minitwit"

set :environment, :test

def app
  Sinatra::Application
end

# standard:disable Style/GlobalVars
RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.expect_with(:rspec) { |c| c.syntax = :expect }

  config.before(:each) do
    $temp_db = Tempfile.new("test.db")
    ENV["DATABASE_PATH"] = $temp_db.path
    $temp_track = Tempfile.new("test.txt")
    ENV["SIM_TRACKER_FILE"] = $temp_track.path
    clean_db
  end

  config.after(:each) do
    $temp_db.close
    $temp_db.unlink
    $temp_track.close
    $temp_track.unlink
  end
end
# standard:enable Style/GlobalVars

def clean_db
  conn = PG.connect(
    host: ENV["DB_HOST"],
    port: ENV["DB_PORT"],
    dbname: ENV["DB_NAME"],
    user: ENV["DB_USER"],
    password: ENV["DB_PASSWORD"]
  )

  conn.exec("SELECT tablename FROM pg_tables WHERE schemaname = 'public';") do |result|
    result.each do |row|
      conn.exec("TRUNCATE \"#{row["tablename"]}\" CASCADE;")
    end
  end

  conn.close
end
