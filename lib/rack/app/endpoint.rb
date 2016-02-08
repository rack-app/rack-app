require 'securerandom'
class Rack::App::Endpoint

  attr_reader :properties

  def initialize(properties)
    @properties = properties

    @error_handler = properties[:error_handler]
    @serializer = properties[:serializer]
    @api_class = properties[:app_class]
    @headers = properties[:default_headers]

    @path_params_matcher = {}
    @endpoint_method_name = register_method_to_app_class(properties[:user_defined_logic])
  end

  def execute(request_env)

    request = Rack::Request.new(request_env)
    response = Rack::Response.new

    add_default_headers(response)
    request_handler = @api_class.new

    request_handler.request = request
    request_handler.response = response
    request.env['rack.app.path_params_matcher']= @path_params_matcher.dup

    call_return = @error_handler.execute_with_error_handling_for(request_handler, @endpoint_method_name)

    return call_return if is_a_rack_response_finish?(call_return)
    add_response_body_if_missing(call_return, response)

    return response.finish

  end

  def register_path_params_matcher(params_matcher)
    @path_params_matcher.merge!(params_matcher)
  end

  protected

  def add_response_body_if_missing(call_return, response)
    response.write(String(@serializer.serialize(call_return))) if response.body.empty?
  end

  def is_a_rack_response_finish?(call_return)
    call_return.is_a?(Array) and
        call_return.length == 3 and
        call_return[0].is_a?(Integer) and
        call_return[1].is_a?(Hash)
  end

  def add_default_headers(response)
    @headers.each do |header, value|
      response.header[header]=value
    end
  end

  def register_method_to_app_class(proc)
    method_name = SecureRandom.uuid
    @api_class.__send__(:define_method, method_name, &proc)
    return method_name
  end

end
