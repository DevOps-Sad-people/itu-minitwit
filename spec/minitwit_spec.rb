require 'spec_helper'

describe 'Root Route' do
  it 'responds with success' do
    get '/public'
    # expect(last_response).to be_ok
    expect(last_response).to include('timeline')
  end
end