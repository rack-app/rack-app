require 'rack'
require 'rack/request'
require 'rack/response'
class Rack::App

  require 'rack/app/version'
  require 'rack/app/constants'

  require 'rack/app/params'
  require 'rack/app/router'
  require 'rack/app/endpoint'
  require 'rack/app/error_handler'
  require 'rack/app/endpoint/not_found'
  require 'rack/app/request_configurator'

  require 'rack/app/utils'
  require 'rack/app/file'

  class << self

    def call(request_env)
      Rack::App::RequestConfigurator.configure(request_env)
      endpoint = router.fetch_endpoint(
          request_env['REQUEST_METHOD'],
          request_env[Rack::App::Constants::NORMALIZED_REQUEST_PATH])
      endpoint.execute(request_env)
    end

    def description(*description_texts)
      @last_description = description_texts.join("\n")
    end

    alias desc description

    def get(path = '/', &block)
      add_route('GET', path, &block)
    end

    def post(path = '/', &block)
      add_route('POST', path, &block)
    end

    def put(path = '/', &block)
      add_route('PUT', path, &block)
    end

    def head(path = '/', &block)
      add_route('HEAD', path, &block)
    end

    def delete(path = '/', &block)
      add_route('DELETE', path, &block)
    end

    def options(path = '/', &block)
      add_route('OPTIONS', path, &block)
    end

    def patch(path = '/', &block)
      add_route('PATCH', path, &block)
    end

    def root(endpoint_path)
      options '/' do
        endpoint = self.class.router.fetch_endpoint('OPTIONS', Rack::App::Utils.normalize_path(endpoint_path))
        endpoint.execute(request.env)
      end
      get '/' do
        endpoint = self.class.router.fetch_endpoint('GET', Rack::App::Utils.normalize_path(endpoint_path))
        endpoint.execute(request.env)
      end
    end

    def error(*exception_classes,&block)
      @error_handler ||= Rack::App::ErrorHandler.new
      unless block.nil?
        @error_handler.register_handler(exception_classes,block)
      end

      return @error_handler
    end

    def router
      @router ||= Rack::App::Router.new
    end

    def add_route(request_method, request_path, &block)

      endpoint_properties = {
          :user_defined_logic => block,
          :request_method => request_method,
          :request_path => request_path,
          :description => @last_description,
          :serializer => @serializer,
          :error_handler => error,
          :app_class => self
      }

      endpoint = Rack::App::Endpoint.new(endpoint_properties)
      router.add_endpoint(request_method, request_path, endpoint)

      @last_description = nil
      return endpoint

    end

    def mount(api_class)

      unless api_class.is_a?(Class) and api_class <= Rack::App
        raise(ArgumentError, 'Invalid class given for mount, must be a Rack::App')
      end

      router.merge!(api_class.router)

      return nil
    end

    def serializer(&code)
      @serializer = code
    end

  end

  def params
    @__params__ ||= Rack::App::Params.new(request.env).to_hash
  end

  attr_writer :request, :response

  def request
    @request || raise("request object is not set for #{self.class}")
  end

  def response
    @response || raise("response object is not set for #{self.class}")
  end

  def payload
    @__payload__ ||= lambda {
      return nil unless @request.body.respond_to?(:gets)

      payload = ''
      while chunk = @request.body.gets
        payload += chunk
      end
      @request.body.rewind

      return payload
    }.call
  end

end