module Rack::App::SingletonMethods::Inheritance

  def on_inheritance(&block)
    @on_inheritance ||= []
    @on_inheritance << block unless block.nil?
    @on_inheritance
  end

  protected

  def inherited(child)

    child.serializer(&serializer.logic)
    [:middlewares, :before, :after].each do |type|
      child.__send__(type).push(*__send__(type))
    end

    on_inheritance.each do |block|
      block.call(self, child)
      child.on_inheritance(&block)
    end

    error.handlers.each do |ex_class, block|
      child.error(ex_class, &block)
    end

  end

end
