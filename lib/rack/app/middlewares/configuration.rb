require "rack/builder"
require "rack/request"
require "rack/response"

class Rack::App::Middlewares::Configuration

  def initialize(app, config)
    @app = app || raise
    @serializer = config.serializer || raise
    @handler_class = config.app_class || raise
    @payload_parser = config.payload_builder.to_parser || raise
  end

  def call(env)
    setup_handler(env)
    env[::Rack::App::Constants::ENV::SERIALIZER] = @serializer
    env[::Rack::App::Constants::ENV::PAYLOAD_PARSER] = @payload_parser
    env[::Rack::App::Constants::ENV::PAYLOAD_GETTER] = lambda do
      env[::Rack::App::Constants::ENV::PARSED_PAYLOAD] ||= env[::Rack::App::Constants::ENV::PAYLOAD_PARSER].parse_env(env)
    end
    @app.call(env)
  end

  protected

  def setup_handler(env)
    request = ::Rack::App::Request.new(env)
    response = ::Rack::Response.new
    h = @handler_class.new
    h.env = env
    h.request = request
    h.response = response
    handlers = ::Rack::App::Handlers.new(env, request, response)
    handlers[@handler_class] = h
    env[::Rack::App::Constants::ENV::HANDLERS] = handlers
    env[::Rack::App::Constants::ENV::HANDLER] = handlers[@handler_class]
  end

  def extname(env)
    path_info = env[::Rack::App::Constants::ENV::PATH_INFO]
    File.extname(path_info.split("/").last.to_s)
  end

end
