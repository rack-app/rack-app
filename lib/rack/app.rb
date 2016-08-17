require 'rack'
require 'rack/builder'
require 'rack/request'
require 'rack/response'
class Rack::App

  require 'rack/app/version'
  require 'rack/app/constants'

  require 'rack/app/cli'
  require 'rack/app/test'
  require 'rack/app/utils'
  require 'rack/app/params'
  require 'rack/app/router'
  require 'rack/app/endpoint'
  require 'rack/app/extension'
  require 'rack/app/serializer'
  require 'rack/app/middlewares'
  require 'rack/app/file_server'
  require 'rack/app/error_handler'
  require 'rack/app/bundled_extensions'
  require 'rack/app/request_configurator'

  require 'rack/app/singleton_methods'
  extend Rack::App::SingletonMethods

  require 'rack/app/instance_methods'
  include Rack::App::InstanceMethods

end
