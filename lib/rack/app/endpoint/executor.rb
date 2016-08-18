class Rack::App::Endpoint::Executor

  def initialize(endpoint_properties)
    @endpoint_properties = endpoint_properties
  end

  def call(env)
    return catch(:rack_response){ execute(env) }.finish
  end

  protected

  def execute(env)
    request_handler = env[Rack::App::Constants::ENV::REQUEST_HANDLER]
    set_response_body(request_handler.response, get_response_body(request_handler))
    return request_handler.response
  end

  def get_response_body(request_handler)
    catch :response_body do
      evaluated_value = evaluate_value(request_handler)

      evaluated_value
    end
  end

  def set_response_body(response, response_body)
    response.write(String(@endpoint_properties.serializer.serialize(response_body)))
  end

  def evaluate_value(request_handler)
    @endpoint_properties.error_handler.execute_with_error_handling_for(request_handler) do
      request_handler.__send__(@endpoint_properties.endpoint_method_name)
    end
  end


end
