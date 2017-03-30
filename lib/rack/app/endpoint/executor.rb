class Rack::App::Endpoint::Executor

  def initialize(endpoint_properties)
    @endpoint_properties = endpoint_properties
  end

  def call(env)
    return catch(:rack_response){ execute(env) }.finish
  end

  protected

  def execute(env)
    request_handler = env[Rack::App::Constants::ENV::HANDLER]
    set_response_body(request_handler, get_response_body(request_handler))
    return request_handler.response
  end

  def get_response_body(request_handler)
    catch :response_body do
      evaluated_value = evaluate_value(request_handler)

      evaluated_value
    end
  end

  EXTNAME = ::Rack::App::Constants::ENV::EXTNAME

  def set_response_body(handler, response_body)
    extname = handler.request.env[EXTNAME]
    handler.response.headers.merge!(@endpoint_properties.serializer.response_headers_for(extname))
    handler.response.write(@endpoint_properties.serializer.serialize(extname, response_body))
  end

  def evaluate_value(request_handler)
    @endpoint_properties.error_handler.execute_with_error_handling_for(request_handler) do
      request_handler.instance_exec(&@endpoint_properties.callable)
    end
  end

end
