module Rack::App::SingletonMethods::Payload
  def payload(&block)
    @payload_builder ||= Rack::App::Payload::Builder.new
    @payload_builder.instance_exec(&block) if block
    @payload_builder
  end

  # def validate_payload(&block)
  #   route_registration_properties[:payload]= descriptor
  # end
end
