module Rack::App::InstanceMethods::Core

  attr_writer :request, :response

  def params
    request.env[::Rack::App::Constants::ENV::PARSED_PARAMS] ||= Rack::App::Params.new(request.env).to_hash
  end

  def validated_params
    request.env[::Rack::App::Constants::ENV::VALIDATED_PARAMS]
  end

  def request
    @request || raise("request object is not set for #{self.class}")
  end

  def response
    @response || raise("response object is not set for #{self.class}")
  end

  def finish!(rack_response=response)
    throw(:rack_response, rack_response)
  end

  alias finish_response finish!
  Rack::App::Utils.deprecate(self, :finish_response, :finish!, 2016,9)

  def respond_with(respond_body)
    throw(:response_body, respond_body)
  end

end
