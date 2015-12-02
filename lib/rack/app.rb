require 'rack'
require 'rack/request'
require 'rack/response'
class Rack::App

  require 'rack/app/version'

  require 'rack/app/params'
  require 'rack/app/utils'
  require 'rack/app/router'
  require 'rack/app/endpoint'
  require 'rack/app/endpoint/not_found'

  class << self

    def call(request_env)
      endpoint = router.fetch_endpoint(request_env['REQUEST_METHOD'],request_env['REQUEST_PATH'])
      endpoint.execute(request_env)
    end

    def description(*description_texts)
      @last_description = description_texts.join("\n")
    end

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

    def router
      @router ||= Rack::App::Router.new
    end

    def add_route(request_method, request_path, &block)

      endpoint_properties = {
          request_method: request_method,
          request_path: request_path,
          description: @last_description
      }

      endpoint = Rack::App::Endpoint.new(
          self, endpoint_properties, &block
      )

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

  end

  def params
    @__params__ ||= Rack::App::Params.new(request.env).to_hash
  end

  def status(new_status=nil)
    response.status= new_status.to_i unless new_status.nil?

    response.status
  end

  attr_writer :request, :response

  def request
    @request || raise("request object is not set for #{self.class}")
  end

  def response
    @response || raise("response object is not set for #{self.class}")
  end

end