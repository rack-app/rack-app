require "rack/builder"
require "rack/request"
require "rack/response"
class Rack::App::Middlewares::Configuration

  require "rack/app/middlewares/configuration/handler_setter"
  require "rack/app/middlewares/configuration/serializer_setter"
  require "rack/app/middlewares/configuration/payload_parser_setter"

  require "rack/app/middlewares/configuration/path_params_matcher"

  def initialize(app, config)
    @stack = build_stack(app) do |builder|
      builder.use Rack::App::Middlewares::Configuration::SerializerSetter,
                  config.serializer

      builder.use Rack::App::Middlewares::Configuration::HandlerSetter,
                  config.app_class

    end
  end

  def call(env)
    @stack.call(env)
  end

  protected

  def build_stack(app)
    builder = Rack::Builder.new
    yield(builder)
    builder.run(app)
    return builder.to_app
  end
end
