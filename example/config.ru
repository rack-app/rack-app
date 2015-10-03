$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),'..','lib'))
require 'rack/api'

class SampleApi < Rack::API

  get '/hello' do
    'Hello World!'
  end

  get '/nope' do
    response.write 'nope nope nope...'
  end

end

run SampleApi