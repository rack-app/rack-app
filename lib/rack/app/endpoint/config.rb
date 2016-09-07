class Rack::App::Endpoint::Config

  def to_hash
    app_class
    serializer
    error_handler
    middleware_builders_blocks
    endpoint_method_name
    return @raw
  end

  def app_class
    @raw[:app_class] || raise('missing app class')
  end

  def serializer
    @raw[:serializer] ||= Rack::App::Serializer.new
  end

  def error_handler
    @raw[:error_handler] ||= Rack::App::ErrorHandler.new
  end

  def middleware_builders_blocks
    @raw[:middleware_builders_blocks] ||= []
  end

  def endpoint_method_name
    @raw[:method_name] ||= register_method_to_app_class
  end

  protected

  def initialize(raw)
    @raw = raw
  end

  def register_method_to_app_class
    method_name = '__' + ::Rack::App::Utils.uuid
    app_class.__send__(:define_method, method_name, &logic_block)
    return method_name
  end

  def logic_block
    @raw[:user_defined_logic]
  end

end
