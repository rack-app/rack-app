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
      request_env = Rack::App::Test::Utils.request_env_by(request_method, url, properties)

      # request = Rack::MockRequest.new(rack_app)
      # Rack::App::Test::Utils.
      # @last_response = request.__send__(request_method, url, env)

      raw_response = rack_app.call(request_env)

      body = []
      raw_response[2].each do |e|
        body << e
      end

      return Rack::Response.new(body, raw_response[0], raw_response[1])

    end
  end

end