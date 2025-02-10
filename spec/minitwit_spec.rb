require 'spec_helper'

def register(username, password, password2 = nil, email = nil)
  password2 ||= password
  email ||= "#{username}@example.com"
  post '/register', { username: username, password: password, password2: password2, email: email }
  
  if last_response.redirect?
    follow_redirect!
  end
end

def login(username, password)
  post '/login', { username: username, password: password }
  follow_redirect!
end

def add_message(text)
  post '/add_message', { text: text }
  expect(last_response.body).to include("Your message was recorded")
  follow_redirect!
end

def register_and_login(username, password)
  register(username, password)
  login(username, password)
end

def logout()
  get '/logout'
  follow_redirect!
end

describe 'Full application test' do
  it 'Simple test' do
    register('user1', 'default')
    expect(last_response.body).to include('You were successfully registered and can login now')
  end

  it 'Register' do
    register('user1', 'default')
    expect(last_response.body).to include('You were successfully registered and can login now')

    register('user1', 'default')
    expect(last_response.body).to include('The username is already taken')

    register('', 'default')
    expect(last_response.body).to include('You have to enter a username')

    register('user2', '')
    expect(last_response.body).to include('You have to enter a password')

    register('user2', 'default', 'default2')
    expect(last_response.body).to include('The two passwords do not match')

    register('user2', 'ye', 'ye', 'broken')
    expect(last_response.body).to include('You have to enter a valid email address')
  end

  it 'Login & logout' do
    register_and_login('user1', 'default')
    expect(last_response.body).to include('You were logged in')

    logout()
    expect(last_response.body).to include('You were logged out')

    login('user1', 'wrongpassword')
    expect(last_response.body).to include('Invalid password')

    login('user2', 'default')
    expect(last_response.body).to include('Invalid username')
  end
end