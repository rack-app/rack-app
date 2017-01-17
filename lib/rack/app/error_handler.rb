class Rack::App::ErrorHandler

  attr_reader :handlers

  def initialize
    @handlers = {}
  end

  def register_handler(exception_classes, handler_block)
    exception_classes.each do |exception_class|
      @handlers[exception_class]= handler_block
    end
    nil
  end

  def execute_with_error_handling_for(instance)
    yield
  rescue *[Exception, @handlers.keys].flatten => ex
    instance.instance_exec(ex, &get_handler(ex))
  end

  protected

  def get_handler(ex)
    explicit(ex) || parent(ex) || raise(ex)
  end

  def explicit(ex)
    @handlers[ex.class]
  end

  def parent(ex)
    handler = @handlers.find { |exception_class, _| ex.class <= exception_class }
    return handler.nil? ? nil : handler.last
  end

end
