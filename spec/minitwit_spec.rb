require 'spec_helper'

describe 'Public Route' do
  it 'responds with success' do
    get '/public'
    expect(last_response).to be_ok
    #expect(last_response).to include('timeline')
  end
end