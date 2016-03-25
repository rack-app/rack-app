require 'uri'
require 'rack/app'
module Rack::App::Test

  require 'rack/app/test/utils'
  require 'rack/app/test/singleton_methods'

  def self.included(klass)
    klass.__send__(:extend, self::SingletonMethods)
  end

  attr_reader :last_response

  [:get, :post, :put, :delete, :options, :patch].each do |request_method|
    define_method(request_method) do |properties|

      properties ||= Hash.new
      url = properties.delete(:url)

      request = Rack::MockRequest.new(rack_app)
      env = Rack::App::Test::Utils.env_by(properties)

      return @last_response = request.__send__(request_method, url, env)

    end
  end

end