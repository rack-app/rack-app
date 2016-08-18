module Rack::App::SingletonMethods

  require 'rack/app/singleton_methods/http_methods'
  require 'rack/app/singleton_methods/inheritance'
  require 'rack/app/singleton_methods/middleware'
  require 'rack/app/singleton_methods/mounting'
  require 'rack/app/singleton_methods/params_validator'
  require 'rack/app/singleton_methods/rack_interface'
  require 'rack/app/singleton_methods/route_handling'
  require 'rack/app/singleton_methods/settings'
  require 'rack/app/singleton_methods/extensions'
  require 'rack/app/singleton_methods/hooks'

  include Rack::App::SingletonMethods::HttpMethods
  include Rack::App::SingletonMethods::Inheritance
  include Rack::App::SingletonMethods::Middleware
  include Rack::App::SingletonMethods::Mounting
  include Rack::App::SingletonMethods::ParamsValidator
  include Rack::App::SingletonMethods::RackInterface
  include Rack::App::SingletonMethods::RouteHandling
  include Rack::App::SingletonMethods::Settings
  include Rack::App::SingletonMethods::Extensions
  include Rack::App::SingletonMethods::Hooks

end
