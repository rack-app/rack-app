class Rack::App::Middlewares::PayloadParserSetter

  PARSER = ::Rack::App::Constants::ENV::PAYLOAD_PARSER
  PARSED = ::Rack::App::Constants::ENV::PARSED_PAYLOAD
  GETTER = ::Rack::App::Constants::ENV::PAYLOAD_GETTER

  def initialize(app, payload_parser)
    @payload_parser = payload_parser
    @app = app
  end

  def call(env)
    env[PARSER]= @payload_parser
    env[GETTER]= lambda { env[PARSED] ||= env[PARSER].parse_env(env) }
    @app.call(env)
  end

end
