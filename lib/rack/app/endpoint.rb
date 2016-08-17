require "rack/builder"
class Rack::App::Endpoint
  require "rack/app/endpoint/properties"

  def properties
    @properties.to_hash
  end

  LAST_MODIFIED_HEADER = "Last-Modified".freeze

  def initialize(properties)
    @properties = Rack::App::Endpoint::Properties.new(properties)
    @endpoint_method_name = register_method_to_app_class(properties[:user_defined_logic])
  end

  def call(env)
    to_app.call(env)
  end 

  def to_app
    builder = Rack::Builder.new
    apply_middleware_build_blocks(builder)
    builder.run(lambda { |env| self.call_without_middlewares(env) })
    builder.to_app
  end

  protected

  def apply_middleware_build_blocks(builder)
    builder_blocks.each do |builder_block|
      builder_block.call(builder)
    end
  end

  def builder_blocks
    @properties.app_class.middlewares + @properties.middleware_builders_blocks
  end

  def call_without_middlewares(env)
    request = Rack::Request.new(env)
    response = Rack::Response.new
    return catch(:rack_response){ execute(request, response) }.finish
  end

  def execute(request,response)
    request_handler = @properties.app_class.new
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
    response.write(String(@properties.serializer.serialize(response_body)))
  end

  def evaluate_value(request_handler)
    @properties.error_handler.execute_with_error_handling_for(request_handler) do
      request_handler.__send__(@endpoint_method_name)
    end
  end

  def register_method_to_app_class(proc)
    method_name = '__' + ::Rack::App::Utils.uuid
    @properties.app_class.__send__(:define_method, method_name, &proc)
    return method_name
  end
end
