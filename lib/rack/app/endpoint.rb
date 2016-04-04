class Rack::App::Endpoint

  attr_reader :properties

  LAST_MODIFIED_HEADER = "Last-Modified".freeze

  def initialize(properties)
    @properties = properties

    @app_class = properties[:app_class]
    @error_handler = properties[:error_handler] || Rack::App::ErrorHandler.new
    @serializer = properties[:serializer] || Rack::App::Serializer.new

    @middleware = (properties[:middleware] || Rack::Builder.new).dup
    @middleware.run(lambda { |env| self.execute(env) })

    @path_params_matcher = {}
    @endpoint_method_name = register_method_to_app_class(properties[:user_defined_logic])

    @app = @middleware.to_app
  end

  def call(env)
    @app.call(env)
  end

  def execute(request_env)

    request = Rack::Request.new(request_env)
    response = Rack::Response.new

    set_response_body(response, get_response_body(request, response))
    return response.finish

  end

  def get_response_body(rack_request, rack_response)

    request_handler = @app_class.new
    request_handler.request = rack_request
    request_handler.response = rack_response

    rack_request.env[::Rack::App::Constants::PATH_PARAMS_MATCHER]= @path_params_matcher.dup
    return @error_handler.execute_with_error_handling_for(request_handler, @endpoint_method_name)

  end

  def register_path_params_matcher(params_matcher)
    @path_params_matcher.clear
    @path_params_matcher.merge!(params_matcher)
  end

  protected

  def set_response_body(response, result)
    return nil unless response.body.is_a?(Array)

    response.write(String(@serializer.serialize(result)))
  end

  def register_method_to_app_class(proc)
    method_name = ::Rack::App::Utils.uuid
    @app_class.__send__(:define_method, method_name, &proc)
    return method_name
  end

end
