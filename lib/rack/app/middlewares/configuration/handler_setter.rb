class Rack::App::Middlewares::Configuration::HandlerSetter

  def initialize(app, handler_class)
    @app = app
    @handler_class = handler_class || raise
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
