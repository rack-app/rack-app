require "rack/request"
require "rack/response"
class Rack::App::Middlewares::Configuration

  def initialize(app, handler_class)
    @handler_class = handler_class
    @app = app
  end

  def call(env)
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
