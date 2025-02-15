require 'spec_helper'

headers = {'HTTP_CONNECTION' => 'close',
           'CONTENT_TYPE' => 'application/json',
           'HTTP_AUTHORIZATION' => 'Basic c2ltdWxhdG9yOnN1cGVyX3NhZmUh'}

describe 'API test' do
  it 'Register' do
    payload = {'username': 'a', 'email': 'a@a.a', 'pwd': 'a'}
    post '/register?latest=1', payload.to_json, headers
    expect(last_response.status).to eq(204)

    get '/latest', headers
    expect(JSON.parse(last_response.body)['latest']).to eq(1)
  end

  it 'Latest' do
    payload = {'username': 'test', 'email': 'test@test', 'pwd': 'foo'}
    post '/register?latest=1337', payload.to_json, headers
    expect(last_response.status).to eq(204)

    get '/latest', headers
    expect(last_response).to be_successful
    expect(JSON.parse(last_response.body)['latest']).to eq(1337)
  end
end