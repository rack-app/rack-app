$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),'..','lib'))
require 'rack/app'

require_relative 'mounted_controller'

class YourAwesomeApp < Rack::APP

  mount MountedController

  get '/hello' do
    'Hello World!'
  end

  get '/nope' do
    response.write 'nope nope nope...'
  end

  get '/users/:user_id' do
    params['user_id']
  end

end

run YourAwesomeApp