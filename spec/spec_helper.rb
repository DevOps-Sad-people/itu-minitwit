require 'rack/test'
require 'rspec'
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
    $temp_track = Tempfile.new('test.txt')
    ENV['SIM_TRACKER_FILE'] = $temp_track.path
    init_db
  end

  config.after(:each) do
    $temp_db.close
    $temp_db.unlink
    $temp_track.close
    $temp_track.unlink
  end
end
