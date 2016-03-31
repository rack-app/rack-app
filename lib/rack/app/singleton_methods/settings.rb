module Rack::App::SingletonMethods::Settings

  def cli(&block)
    @cli ||= Rack::App::CLI.new
    @cli.instance_exec(&block) unless block.nil?
    @cli
  end

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

  def extensions(*extension_names)
    Rack::App::Extension.apply_extensions(self,*extension_names)
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