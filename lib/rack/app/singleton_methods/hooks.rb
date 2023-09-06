module Rack::App::SingletonMethods::Hooks

  def before(&block)
    @before_hooks ||= []
    unless block.nil?
      @before_hooks << ::Rack::App::Hook.new(class: self, &block)
    end
    @before_hooks
  end

  def after(&block)
    @after_hooks ||= []
    unless block.nil?
      @after_hooks << ::Rack::App::Hook.new(class: self, &block)
    end
    @after_hooks
  end

end
