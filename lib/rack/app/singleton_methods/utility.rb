module Rack::App::SingletonMethods::Utility

  protected

  def serializer(&definition_how_to_serialize)
    @serializer ||= Rack::App::Serializer.new

    unless definition_how_to_serialize.nil?
      @serializer.set_serialization_logic(definition_how_to_serialize)
    end

    return @serializer
  end

  def headers(new_headers=nil)
    @headers ||= {}
    @headers.merge!(new_headers) if new_headers.is_a?(Hash)
    @headers
  end

  def extensions(*extensions)
    extensions.each do |ext|
      if ext.is_a?(::Class) && ext < (::Rack::App::Extension)

        ext.includes.each { |m| include(m) }
        ext.extends.each { |m| extend(m) }
        ext.inheritances.each { |block| on_inheritance(&block) }

      end
    end
  end

  def error(*exception_classes, &block)
    @error_handler ||= Rack::App::ErrorHandler.new
    unless block.nil?
      @error_handler.register_handler(exception_classes, block)
    end

    return @error_handler
  end

  private

  def middlewares(&block)
    @middlewares ||= []
    @middlewares << block unless block.nil?
    @middlewares
  end

  alias middleware middlewares

end