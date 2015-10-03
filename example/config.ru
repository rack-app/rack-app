$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),'..','lib'))
require 'rack/api'

require_relative 'first_controller'

class SampleApi < Rack::API

  mount FirstController

  get '/hello' do
    'Hello World!'
  end

  get '/nope' do
    response.write 'nope nope nope...'

  end

end

run SampleApi