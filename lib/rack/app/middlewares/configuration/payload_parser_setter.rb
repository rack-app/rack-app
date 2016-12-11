class Rack::App::Middlewares::Configuration::PayloadParserSetter

  PARSER = ::Rack::App::Constants::ENV::PAYLOAD_PARSER
  PARSED = ::Rack::App::Constants::ENV::PARSED_PAYLOAD
  GETTER = ::Rack::App::Constants::ENV::PAYLOAD_GETTER

  def initialize(app)
    @app = app
  end

  module DefaultParser
    extend(self)

    def parse_io(io)
      io.read
    end

    def parse_string(str)
      str
    end

    def parse_env(env)
      Rack::Request.new(env).body.read
    end

  end

  def call(env)
    env[PARSER]= DefaultParser
    env[GETTER]= lambda { env[PARSED] ||= env[PARSER].parse_env(env) }
    @app.call(env)
  end

end
