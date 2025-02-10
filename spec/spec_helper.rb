require 'rack/test'
require 'rspec'
require 'factory_bot'
require 'tempfile'
require_relative '../minitwit'

set :environment, :test

def app
  Sinatra::Application
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.expect_with(:rspec) { |c| c.syntax = :expect }

  config.before(:each) do
    $temp_db = Tempfile.new('test.db')
    ENV['DATABASE_PATH'] = $temp_db.path

    init_db
  end

  config.after(:each) do
    $temp_db.close
    $temp_db.unlink
  end
end
