require 'selenium-webdriver'
require 'pg'
require 'rspec'
require_relative '../minitwit'

GUI_URL = "http://0.0.0.0:4567/register"
DB_URL = "postgres://#{ENV.fetch('DB_USER')}:#{ENV.fetch('DB_PASSWORD')}@#{ENV.fetch('DB_HOST')}:#{ENV.fetch('DB_PORT')}/#{ENV.fetch('DB_NAME')}"

GECKODRIVER_PATH = './geckodriver'
FIREFOX_PATH = '../usr/bin/firefox'

def register_user_via_gui(driver, data)
  driver.navigate.to GUI_URL

  wait = Selenium::WebDriver::Wait.new(timeout: 5)
  buttons = wait.until { driver.find_elements(class: 'actions') }
  input_fields = driver.find_elements(tag_name: 'input')

  data.each_with_index do |str_content, idx|
    input_fields[idx].send_keys(str_content)
  end
  input_fields[4].send_keys(:return)

  wait.until { driver.find_elements(class: 'flashes') }
end

def get_user_by_name(conn, name)
  conn.exec_params("SELECT * FROM users WHERE username = $1", [name]).first
end

RSpec.describe 'MiniTwit UI Test' do
  before(:all) do
    @conn = PG.connect(DB_URL)
  end

  after(:all) do
    @conn.close if @conn
  end

  # it 'registers a user via the GUI' do
  #   options = Selenium::WebDriver::Firefox::Options.new
  #   options.add_argument('--headless')
  #   options.binary = '/usr/bin/firefox'

  #   driver = Selenium::WebDriver.for :firefox, options: options, service: Selenium::WebDriver::Service.firefox(path: GECKODRIVER_PATH)

  #   generated_msg = register_user_via_gui(driver, ['Me', 'me@some.where', 'secure123', 'secure123']).first.text
  #   expected_msg = 'You were successfully registered and can login now'
  #   expect(generated_msg).to eq(expected_msg)

  #   driver.quit

  #   # Cleanup, make test case idempotent
  #   @conn.exec_params("DELETE FROM users WHERE username = $1", ['Me'])
  # end

  it 'registers a user via the GUI and checks DB entry' do
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    # options.binary = '/usr/bin/firefox'

    driver = Selenium::WebDriver.for :chrome, options: options
    # driver = Selenium::WebDriver.for :firefox, options: options, service: Selenium::WebDriver::Service.firefox(path: GECKODRIVER_PATH)

    expect(get_user_by_name(@conn, 'Me')).to be_nil

    generated_msg = register_user_via_gui(driver, ['Me', 'me@some.where', 'secure123', 'secure123']).first.text
    expected_msg = 'You were successfully registered and can login now'
    expect(generated_msg).to eq(expected_msg)

    expect(get_user_by_name(@conn, 'Me')['username']).to eq('Me')

    driver.quit

    # Cleanup, make test case idempotent
    @conn.exec_params("DELETE FROM users WHERE username = $1", ['Me'])
  end
end