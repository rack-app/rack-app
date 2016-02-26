require 'rack'
require 'rack/builder'
require 'rack/request'
require 'rack/response'
class Rack::App

  require 'rack/app/version'
  require 'rack/app/constants'

  require 'rack/app/utils'
  require 'rack/app/file'

  require 'rack/app/params'
  require 'rack/app/router'
  require 'rack/app/endpoint'
  require 'rack/app/serializer'
  require 'rack/app/error_handler'
  require 'rack/app/endpoint/not_found'
  require 'rack/app/request_configurator'

  class << self

    def inherited(klass)

      error.handlers.each do |ex_class, block|
        klass.error(ex_class, &block)
      end

      klass.serializer(&serializer.logic)
      middlewares.each { |builder_block| klass.middlewares(&builder_block) }
      klass.headers.merge!(headers)

    end

    def serializer(&definition_how_to_serialize)
      @serializer ||= Rack::App::Serializer.new

      unless definition_how_to_serialize.nil?
        @serializer.set_serialization_logic(definition_how_to_serialize)
      end

      return @serializer
    end

    def headers(new_headers=nil)
      @headers ||= {}
      @headers.merge!(new_headers) if new_headers.is_a?(Hash)
      @headers
    end

    def middlewares(&block)
      @middlewares ||= []
      @middlewares << block unless block.nil?
      @middlewares
    end

    alias middleware middlewares

    def error(*exception_classes, &block)
      @error_handler ||= Rack::App::ErrorHandler.new
      unless block.nil?
        @error_handler.register_handler(exception_classes, block)
      end

      return @error_handler
    end

    def namespace(request_path_namespace)
      return unless block_given?
      @namespaces ||= []
      @namespaces.push(request_path_namespace)
      yield
      @namespaces.pop
      nil
    end

    def router
      @router ||= Rack::App::Router.new
    end

    def call(request_env)
      Rack::App::RequestConfigurator.configure(request_env)
      endpoint = router.fetch_endpoint(
          request_env['REQUEST_METHOD'],
          request_env[Rack::App::Constants::NORMALIZED_REQUEST_PATH])
      endpoint.call(request_env)
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

    def alias_endpoint(new_request_path, original_request_path)
      router.endpoints.select { |ep| ep[:request_path] == original_request_path }.each do |endpoint|
        router.register_endpoint!(endpoint[:request_method], new_request_path, endpoint[:description], endpoint[:endpoint])
      end
    end

    def root(endpoint_path)
      %W[GET POST PUT DELETE OPTIONS PATCH HEAD].each do |request_method|
        endpoint = router.fetch_endpoint(request_method, endpoint_path)
        next if endpoint == Rack::App::Endpoint::NOT_FOUND
        router.register_endpoint!(request_method, '/', 'Root endpoint', endpoint)
      end
    end

    def add_route(request_method, request_path, &block)

      request_path = ::Rack::App::Utils.join(@namespaces, request_path)

      builder = Rack::Builder.new
      middlewares.each do |builder_block|
        builder_block.call(builder)
      end

      properties = {
          :user_defined_logic => block,
          :request_method => request_method,
          :request_path => request_path,

          :default_headers => headers,
          :error_handler => error,
          :description => @last_description,
          :serializer => serializer,
          :middleware => builder,
          :app_class => self
      }


      endpoint = Rack::App::Endpoint.new(properties)
      router.register_endpoint!(request_method, request_path, @last_description, endpoint)

      @last_description = nil
      return endpoint

    end

    def serve_files_from(file_path, options={})
      file_server = Rack::App::File::Server.new(Rack::App::Utils.expand_path(file_path))
      request_path = Rack::App::Utils.join(@namespaces, options[:to], '**', '*')
      router.register_endpoint!('GET', request_path, @last_description, file_server)
      @last_description = nil
    end

    def mount(api_class, mount_prop={})

      unless api_class.is_a?(Class) and api_class <= Rack::App
        raise(ArgumentError, 'Invalid class given for mount, must be a Rack::App')
      end

      merge_prop = {:namespaces => [@namespaces, mount_prop[:to]].flatten}
      router.merge_router!(api_class.router, merge_prop)

      return nil
    end

  end

  attr_writer :request, :response

  def params
    @__params__ ||= Rack::App::Params.new(request.env).to_hash
  end

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
        payload << chunk
      end
      @request.body.rewind

      return payload
    }.call
  end

  def redirect_to(url)
    url = "#{url}?#{request.env['QUERY_STRING']}" unless request.env['QUERY_STRING'].empty?
    response.status = 301
    response.headers.merge!({'Location' => url})
    'See Ya!'
  end

end