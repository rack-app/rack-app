class Rack::App::Middlewares::PayloadParserSetter

  def initialize(app, payload_parser)
    @payload_parser = payload_parser
    @app = app
  end

  def call(env)
    env[::Rack::App::Constants::ENV::PAYLOAD_PARSER]= @payload_parser

    env[Rack::App::Constants::ENV::PAYLOAD_GETTER]= lambda do
      env[Rack::App::Constants::ENV::PARSED_PAYLOAD] ||= lambda do
        parser = env[Rack::App::Constants::ENV::PAYLOAD_PARSER]
        parser.parse_env(env)
      end.call
    end

    @app.call(env)
  end

end
