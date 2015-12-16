class Rack::App::Endpoint

  attr_reader :properties

  def initialize(properties)
    @properties = properties
    @logic_block = properties[:user_defined_logic]
    @serializer = properties[:serializer] || default_serializer
    @api_class = properties[:app_class]

    @path_params_matcher = {}
  end


  def execute(request_env)

    request = Rack::Request.new(request_env)
    response = Rack::Response.new

    request_handler = @api_class.new

    request_handler.request = request
    request_handler.response = response
    request.env['rack.app.path_params_matcher']= @path_params_matcher.dup

    call_return = request_handler.instance_exec(&@logic_block)

    return call_return if is_a_rack_response_finish?(call_return)
    add_response_body_if_missing(call_return, response)

    return response.finish

  end

  def register_path_params_matcher(params_matcher)
    @path_params_matcher.merge!(params_matcher)
  end

  protected

  def add_response_body_if_missing(call_return, response)
    response.write(String(@serializer.call(call_return))) if response.body.empty?
  end

  def is_a_rack_response_finish?(call_return)
    call_return.is_a?(Array) and
        call_return.length == 3 and
        call_return[0].is_a?(Integer) and
        call_return[1].is_a?(Hash)
  end

  def default_serializer
    lambda { |o| o.to_s }
  end

end
