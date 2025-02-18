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

  it 'Follows' do
    payload = {'username': 'a', 'email': 'a@a.a', 'pwd': 'a'}
    post '/register?latest=1', payload.to_json, headers
    payload = {'username': 'b', 'email': 'b@b.b', 'pwd': 'b'}
    post '/register?latest=1', payload.to_json, headers
    payload = {'username': 'c', 'email': 'c@c.c', 'pwd': 'c'}
    post '/register?latest=1', payload.to_json, headers

    username = 'a'
    payload = {'follow': 'b'}

    post "/fllws/#{username}?latest=7", payload.to_json, headers
    expect(last_response.status).to eq(204)

    payload = {'follow': 'c'}
    post "/fllws/#{username}?latest=8", payload.to_json, headers
    expect(last_response.status).to eq(204)

    get "/fllws/#{username}?latest=9&no=20", nil, headers
    expect(last_response).to be_successful

    json_response = JSON.parse(last_response.body)
    expect(json_response['follows']).to include('b', 'c')


    get '/latest', headers
    expect(last_response).to be_successful
    expect(JSON.parse(last_response.body)['latest']).to eq(9)
  end

  it 'Unfollows' do
    payload = {'username': 'a', 'email': 'a@a.a', 'pwd': 'a'}
    post '/register?latest=1', payload.to_json, headers
    payload = {'username': 'b', 'email': 'b@b.b', 'pwd': 'b'}
    post '/register?latest=1', payload.to_json, headers

    username = 'a'
    payload = {'follow': 'b'}
    post "/fllws/#{username}?latest=10", payload.to_json, headers
    
    payload = {'unfollow': 'b'}
    post "/fllws/#{username}?latest=11", payload.to_json, headers
    expect(last_response.status).to eq(204)

    get "/fllws/#{username}?latest=12&no=20", nil, headers
    expect(last_response).to be_successful

    json_response = JSON.parse(last_response.body)
    expect(json_response['follows']).not_to include('b')


    get '/latest', headers
    expect(last_response).to be_successful
    expect(JSON.parse(last_response.body)['latest']).to eq(12)
  end

  it 'Test create message' do
    payload = {'username': 'a', 'email': 'a@a.a', 'pwd': 'a'}
    post '/register?latest=1', payload.to_json, headers

    username = 'a'
    payload = {'message': 'test'}
    post "/msgs/#{username}?latest=2", payload.to_json, headers

    expect(last_response.status).to eq(204)

    # verify that latest was updated
    get '/latest', headers
    expect(last_response).to be_successful
    expect(JSON.parse(last_response.body)['latest']).to eq(2)
  end

  it 'Test get lastest user messages' do
    payload = {'username': 'a', 'email': 'a@a.a', 'pwd': 'a'}
    post '/register?latest=1', payload.to_json, headers

    posted_msg = 'Test get lastest user messages'
    payload = {'message': posted_msg}
    post "/msgs/a?latest=2", payload.to_json, headers

    expect(last_response.status).to eq(204)

    get '/msgs/a?latest=3&no=20', nil, headers
    expect(last_response).to be_successful

    got_it_earlier = false
    JSON.parse(last_response.body).each do |msg|

      if msg['content'] == posted_msg && msg['user'] == 'a'
        got_it_earlier = true
        break
      end
    end

    expect(got_it_earlier).to be true

    # verify that latest was updated
    get '/latest', headers
    expect(last_response).to be_successful
    expect(JSON.parse(last_response.body)['latest']).to eq(3)
  end

  it 'Test get lastest messages' do
    payload = {'username': 'a', 'email': 'a@a.a', 'pwd': 'a'}
    post '/register?latest=1', payload.to_json, headers

    posted_msg = 'Test get lastest messages'
    payload = {'message': posted_msg}
    post "/msgs/a?latest=2", payload.to_json, headers

    expect(last_response.status).to eq(204)

    get '/msgs?latest=4&no=20', nil, headers
    expect(last_response).to be_successful

    got_it_earlier = false
    JSON.parse(last_response.body).each do |msg|
      if msg['content'] == posted_msg && msg['user'] == 'a'
        got_it_earlier = true
        break
      end
    end

    expect(got_it_earlier).to be true

    # verify that latest was updated
    get '/latest', headers
    expect(last_response).to be_successful
    expect(JSON.parse(last_response.body)['latest']).to eq(4)
  end

end