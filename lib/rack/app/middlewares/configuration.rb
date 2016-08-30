require "rack/request"
require "rack/response"
class Rack::App::Middlewares::Configuration

  require "rack/app/middlewares/configuration/path_info_formatter"
  require "rack/app/middlewares/configuration/path_params_matcher"

  def initialize(app, options={})
    @handler_class = options[:app_class] || raise
    @serializer = options[:serializer] || raise
    @app = app
  end

  def call(env)
    env[Rack::App::Constants::ENV::SERIALIZER]= @serializer
    env[Rack::App::Constants::ENV::REQUEST_HANDLER]= handler(env)
    @app.call(env)
  end

  protected

  def handler(env)
    new_handler = @handler_class.new
    new_handler.request = ::Rack::Request.new(env)
    new_handler.response = ::Rack::Response.new
    new_handler
  end

end
