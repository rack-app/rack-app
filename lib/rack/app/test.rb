require "uri"
require "rack/app"
require "rack/mock"
module Rack::App::Test

  require 'rack/app/test/utils'
  require 'rack/app/test/singleton_methods'

  def self.included(klass)
    klass.__send__(:extend, self::SingletonMethods)
  end

  attr_reader :last_response

  Rack::App::Constants::HTTP::METHODS.each do |request_method_type|
    request_method = request_method_type.to_s.downcase
    define_method(request_method) do |*args|

      properties = args.select { |e| e.is_a?(Hash) }.reduce({}, &:merge!)
      url = args.select { |e| e.is_a?(String) }.first || properties.delete(:url)
      mock_request = Rack::MockRequest.new(rack_app)
      request_env = Rack::App::Test::Utils.env_by(properties)
      return @last_response = mock_request.request(request_method, url, request_env)

    end
  end

  def rack_app(&block)
    @rack_app ||= lambda do
      if defined?(__rack_app_class__)
        __rack_app_class__
      elsif defined?(described_class) && described_class.respond_to?(:call)
        described_class
      else
        raise('missing class definition')
      end
    end.call 
    block.is_a?(Proc) ? @rack_app.instance_exec(&block) : @rack_app
  end

end
