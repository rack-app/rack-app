module Rack::API::Runner
  extend self

  def response_for(api_class, request_env)

    request = Rack::Request.new(request_env)
    response = Rack::Response.new
    api_request_handler = api_class.new(request, response)

    block = fetch_endpoint_block(
        api_class,
        api_request_handler,
        request_env['REQUEST_METHOD'],
        request_env['REQUEST_PATH']
    )

    call_return = api_request_handler.instance_exec(&block)
    return call_return if call_return.is_a?(Array)
    add_response_body_if_missing(call_return, response)

    return response.finish

  end

  protected

  def add_response_body_if_missing(call_return, response)
    response.write(call_return.to_s) if response.body.empty?
  end

  def fetch_endpoint_block(api_class, handler, request_method, request_path)
    block = api_class.endpoints[[request_method, request_path]]
    block || handler.method(:request_path_not_found)
  end

end