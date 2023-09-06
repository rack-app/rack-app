module Rack::App::InstanceMethods::Core

  attr_writer :env, :request, :response

  def env
    @env || raise("env object is not set for #{self.class}")
  end

  def request
    @request || raise("request object is not set for #{self.class}")
  end

  def response
    @response || raise("response object is not set for #{self.class}")
  end

  def respond_with(value = response)
    case value
    when Rack::Response
      throw(:rack_response, value)
    else
      throw(:response_body, value)
    end
  end

  alias finish! respond_with

end
