class Rack::App::Endpoint::Executor

  def initialize(endpoint_properties)
    @endpoint_properties = endpoint_properties
    @catcher = Rack::App::Endpoint::Catcher.new(proc{ |env| execute(env) }, endpoint_properties)
  end

  def call(env)
    @catcher.call(env)
  end

  protected

  def execute(env)
    resp = evaluate_value(env[Rack::App::Constants::ENV::HANDLER])
    throw type(resp), resp
  end

  def type(resp)
    resp.is_a?(Rack::Response) ? :rack_response : :response_body
  end

  def evaluate_value(request_handler)
    @endpoint_properties.error_handler.execute_with_error_handling_for(request_handler) do
      request_handler.instance_exec(&@endpoint_properties.callable)
    end
  end

end
