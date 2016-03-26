module Rack::App::SingletonMethods

  require 'rack/app/singleton_methods/http_methods'
  require 'rack/app/singleton_methods/inheritance'
  require 'rack/app/singleton_methods/mounting'
  require 'rack/app/singleton_methods/rack_interface'
  require 'rack/app/singleton_methods/route_handling'
  require 'rack/app/singleton_methods/settings'

  include Rack::App::SingletonMethods::HttpMethods
  include Rack::App::SingletonMethods::Inheritance
  include Rack::App::SingletonMethods::Mounting
  include Rack::App::SingletonMethods::RackInterface
  include Rack::App::SingletonMethods::RouteHandling
  include Rack::App::SingletonMethods::Settings

end