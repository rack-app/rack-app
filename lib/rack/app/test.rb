require 'uri'
require 'rack/mock'
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
    @last_response = mock_request.request(request_method.to_s.upcase, url, request_env)
  end

  Rack::App::Constants::HTTP::METHODS.each do |request_method_type|
    define_method(request_method_type.to_s.downcase) do |*args|
      __send_rack_app_request__(request_method_type, *args)
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

  def mount(app_class, options)
    path_prefix = options.fetch(:to)

    selector = lambda do |e|
      if e.config.type == :endpoint
        e.config.app_class == app_class
      else
        e.config.callable == app_class
      end
    end

    endpoints = rack_app.router.endpoints.select(&selector)

    request_paths_that_has_prefix = lambda do |e|
      e.request_path.start_with?(path_prefix)
    end

    matching_endpoints = endpoints.select(&request_paths_that_has_prefix)

    if matching_endpoints.empty?
      raise("Can't find any path that fullfill the requirement")
    end

    return unless app_class.is_a?(Class) && app_class <= Rack::App
    app_owned_endpoints = app_class.router.endpoints.select(&selector)

    if matching_endpoints.length != app_owned_endpoints.length
      raise('endpoint count not matching')
    end
  end
end
