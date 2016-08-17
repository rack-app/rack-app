class Rack::App::Endpoint::Properties

  def to_hash 
    @raw
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

  protected

  def initialize(raw)
    @raw = raw
  end

end
