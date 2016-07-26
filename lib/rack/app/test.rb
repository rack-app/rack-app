require 'uri'
require 'rack/app'
module Rack::App::Test

  require 'rack/app/test/utils'
  require 'rack/app/test/singleton_methods'

  def self.included(klass)
    klass.__send__(:extend, self::SingletonMethods)
  end

  attr_reader :last_response

  [:get, :post, :put, :delete, :options, :patch, :head].each do |request_method|
    define_method(request_method) do |*args|

      properties = args.select { |e| e.is_a?(Hash) }.reduce({}, &:merge!)
      url = args.select { |e| e.is_a?(String) }.first || properties.delete(:url)
      mock_request = Rack::MockRequest.new(rack_app)
      request_env = Rack::App::Test::Utils.env_by(properties)
      return @last_response = mock_request.request(request_method, url, request_env)

    end
  end

  def rack_app(&block)

    @app ||= lambda do
      app_class = defined?(__rack_app_class__) ? __rack_app_class__ : nil
      constructors = []
      if defined?(__rack_app_constructor__) and __rack_app_constructor__.is_a?(Proc)
        constructors << __rack_app_constructor__
      end
      Rack::App::Test::Utils.rack_app_by(app_class, constructors)
    end.call

    block.is_a?(Proc) ? @app.instance_exec(&block) : @app

  end

end
