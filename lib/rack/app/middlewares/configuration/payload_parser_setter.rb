class Rack::App::Middlewares::Configuration::PayloadParserSetter

  PARSER = ::Rack::App::Constants::ENV::PAYLOAD_PARSER
  PARSED = ::Rack::App::Constants::ENV::PARSED_PAYLOAD
  GETTER = ::Rack::App::Constants::ENV::PAYLOAD_GETTER

  def initialize(app)
    @app = app
    @parser = Rack::App::Payload::Parser.new 
  end

  def call(env)
    env[PARSER]= @parser
    env[GETTER]= lambda { env[PARSED] ||= env[PARSER].parse_env(env) }
    @app.call(env)
  end

end
