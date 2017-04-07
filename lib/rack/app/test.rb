require "uri"
require "rack/mock"
module Rack::App::Test

  require 'rack/app/test/utils'
  require 'rack/app/test/singleton_methods'

  def self.included(klass)
    klass.__send__(:extend, self::SingletonMethods)
  end

  attr_reader :last_response

  def __send_rack_app_request__(request_method, *args)
    properties = args.select { |e| e.is_a?(Hash) }.reduce({}, &:merge!)
    url = args.detect { |e| e.is_a?(String) } || properties.delete(:url)
    mock_request = Rack::MockRequest.new(rack_app)
    request_env = Rack::App::Test::Utils.env_by(url, properties)
    return @last_response = mock_request.request(request_method.to_s.upcase, url, request_env)
  end

  Rack::App::Constants::HTTP::METHODS.each do |request_method_type|
    define_method(request_method_type.to_s.downcase) do |*args|
      self.__send_rack_app_request__(request_method_type, *args)
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
