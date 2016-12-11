class Rack::App::Middlewares::Payload::ParserSetter

  PARSER = ::Rack::App::Constants::ENV::PAYLOAD_PARSER
  PARSED = ::Rack::App::Constants::ENV::PARSED_PAYLOAD
  GETTER = ::Rack::App::Constants::ENV::PAYLOAD_GETTER

  def initialize(app, payload_builder)
    @payload_parser = payload_builder.parser.to_parser
    @app = app
  end

  def call(env)
    env[PARSER]= @payload_parser
    env[GETTER]= lambda { env[PARSED] ||= env[PARSER].parse_env(env) }
    @app.call(env)
  end

end
