module Rack::App::SingletonMethods::Settings

  def cli(&block)
    @cli ||= Rack::App::CLI.new
    @cli.instance_exec(&block) unless block.nil?
    @cli
  end

  protected

  def headers(new_headers=nil)
    middleware do |b|
      b.use(Rack::App::Middlewares::HeaderSetter,new_headers)
    end if new_headers.is_a?(Hash)

    new_headers
  end

  def error(*exception_classes, &block)
    @error_handler ||= Rack::App::ErrorHandler.new
    unless block.nil?
      @error_handler.register_handler(exception_classes, block)
    end

    return @error_handler
  end

end
