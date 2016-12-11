module Rack::App::SingletonMethods::Payload

  def payload(&block)
    payload_builder = Rack::App::Payload::Builder.new(&block)
    use(Rack::App::Middlewares::Payload::ParserSetter, payload_builder.parser.to_parser)
  end

end
