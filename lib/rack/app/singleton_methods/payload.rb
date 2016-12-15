module Rack::App::SingletonMethods::Payload

  def payload(&block)
    @payload_builder ||= Rack::App::Payload::Builder.new
    @payload_builder.instance_exec(&block) if block
    @payload_builder
  end

end
