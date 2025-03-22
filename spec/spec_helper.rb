require 'rack/test'
require 'rspec'
require 'tempfile'
require 'pg'
require 'sequel'
require_relative '../minitwit'
require_relative '../db_migrations'

set :environment, :test

def app
  Sinatra::Application
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.expect_with(:rspec) { |c| c.syntax = :expect }

  config.before(:each) do
    clean_db
  end

  config.after(:each) do
    clean_db
  end
end

def clean_db
  db_url = "postgres://#{ENV.fetch('DB_USER')}:#{ENV.fetch('DB_PASSWORD')}@#{ENV.fetch('DB_HOST')}:#{ENV.fetch('DB_PORT')}/#{ENV.fetch('DB_NAME')}"
  db = Sequel.connect(db_url)
  db[:message].delete
  db[:follower].delete
  db[:user].delete
  db.disconnect
end