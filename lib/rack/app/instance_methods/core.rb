module Rack::App::InstanceMethods::Core

  attr_writer :request, :response

  def params
    @__params__ ||= Rack::App::Params.new(request.env).to_hash
  end

  def request
    @request || raise("request object is not set for #{self.class}")
  end

  def response
    @response || raise("response object is not set for #{self.class}")
  end

end

