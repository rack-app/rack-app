module Rack::App::SingletonMethods::Inheritance

  protected

  def inherited(child)

    parent = self

    parent_serializer_logic = serializer.logic
    parent_headers = headers
    parent_middlewares = middlewares
    parent_inheritance_blocks = on_inheritance
    parent_error_handlers = error.handlers

    child.class_eval do

      serializer(&parent_serializer_logic)
      headers.merge!(parent_headers)
      middlewares.push(*parent_middlewares)

      parent_inheritance_blocks.each do |block|
        block.call(parent, self)
        on_inheritance(&block)
      end

      parent_error_handlers.each do |ex_class, block|
        error(ex_class, &block)
      end

    end

  end

  def on_inheritance(&block)
    @on_inheritance ||= []
    @on_inheritance << block unless block.nil?
    @on_inheritance
  end

end