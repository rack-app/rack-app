require 'spec_helper'
describe Rack::App do

  require "rack/app/test"
  include Rack::App::Test

  rack_app do
    get '/found' do
      'OK'
    end
  end


  it 'should set the response body to 404 Not Found' do
    expect(get('/nothing_here').body).to eq '404 Not Found'
  end

  it 'should set the response status to 404' do
    expect(get('/nothing_here').status).to eq 404
  end

end
