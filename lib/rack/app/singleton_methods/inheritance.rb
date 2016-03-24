module Rack::App::SingletonMethods::Inheritance

  protected

  def inherited(klass)

    klass.serializer(&serializer.logic)
    klass.headers.merge!(headers)
    klass.middlewares.push(*middlewares)

    on_inheritance.each do |block|
      block.call(self, klass)
      klass.on_inheritance(&block)
    end

    error.handlers.each do |ex_class, block|
      klass.error(ex_class, &block)
    end

  end

  def on_inheritance(&block)
    @on_inheritance ||= []
    @on_inheritance << block unless block.nil?
    @on_inheritance
  end

end