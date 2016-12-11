module Rack::App::SingletonMethods::Payload

  def payload(&block)
    unless @payload_builder
      @payload_builder = Rack::App::Payload::Builder.new
      use(Rack::App::Middlewares::Payload::ParserSetter, @payload_builder)
    end
    @payload_builder.instance_exec(&block) if block
    nil 
  end

end
