require 'spec_helper'

headers = {'HTTP_CONNECTION' => 'close',
           'CONTENT_TYPE' => 'application/json',
           'HTTP_AUTHORIZATION' => 'Basic c2ltdWxhdG9yOnN1cGVyX3NhZmUh'}

describe 'API test' do
  it 'Register' do
    payload = {'username': 'a', 'email': 'a@a.a', 'pwd': 'a'}
    post '/register?latest=1', payload.to_json, headers
    expect(last_response.status).to eq(204)

    # Check if /latest return 1
  end
end