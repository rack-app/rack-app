class Rack::App::Endpoint

  attr_reader :properties

  LAST_MODIFIED_HEADER = "Last-Modified".freeze

  def initialize(properties)
    @properties = properties

    @app_class = properties[:app_class]
    @error_handler = properties[:error_handler] || Rack::App::ErrorHandler.new
    @serializer = properties[:serializer] || Rack::App::Serializer.new

    middleware = (properties[:middleware] || Rack::Builder.new).dup
    middleware.run(lambda { |env| self.call_without_middlewares(env) })
    @endpoint_method_name = register_method_to_app_class(properties[:user_defined_logic])

    @app = middleware.to_app
  end

  def call(env)
    @app.call(env)
  end

  def call_without_middlewares(env)
    request = Rack::Request.new(env)
    response = Rack::Response.new
    return catch(:rack_response){ execute(request, response) }.finish
  end

  protected

  def execute(request,response)
    request_handler = @app_class.new
    request_handler.request = request
    request_handler.response = response
    set_response_body(response, get_response_body(request_handler))
    return response
  end

  def get_response_body(request_handler)
    catch :response_body do
      evaluated_value = evaluate_value(request_handler)
      
      evaluated_value
    end
  end

  def set_response_body(response, response_body)
    response.write(String(@serializer.serialize(response_body)))
  end

  def evaluate_value(request_handler)
    @error_handler.execute_with_error_handling_for(request_handler) do
      request_handler.__send__(@endpoint_method_name)
    end
  end

  def register_method_to_app_class(proc)
    method_name = '__' + ::Rack::App::Utils.uuid
    @app_class.__send__(:define_method, method_name, &proc)
    return method_name
  end
end
