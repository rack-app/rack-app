class Rack::App::Middlewares::PayloadParserSetter

  def initialize(app, payload_parser)
    @payload_parser = payload_parser
    @app = app
  end

  def call(env)
    env[::Rack::App::Constants::ENV::PAYLOAD_PARSER]= @payload_parser
    @app.call(env)
  end

end
