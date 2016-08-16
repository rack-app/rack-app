module Rack::App::InstanceMethods::Core

  attr_writer :request, :response

  def params
    request.env[::Rack::App::Constants::PARSED_PARAMS] ||= Rack::App::Params.new(request.env).to_hash
  end

  def validated_params
    request.env[::Rack::App::Constants::VALIDATED_PARAMS]
  end

  def request
    @request || raise("request object is not set for #{self.class}")
  end

  def response
    @response || raise("response object is not set for #{self.class}")
  end

  def finish_response
    throw(:rack_response, response)
  end

end
