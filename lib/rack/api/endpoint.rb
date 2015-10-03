class Rack::API::Endpoint

  def initialize(api_class, properties={}, &logic_block)
    @properties = properties
    @logic_block = logic_block
    @api_class = api_class
  end

  def execute(request_env)

    request = Rack::Request.new(request_env)
    response = Rack::Response.new

    request_handler = @api_class.new(request, response)
    call_return = request_handler.instance_exec(&@logic_block)

    return call_return if call_return.is_a?(Array)
    add_response_body_if_missing(call_return, response)

    return response.finish

  end

  protected

  def add_response_body_if_missing(call_return, response)
    response.write(call_return.to_s) if response.body.empty?
  end

end