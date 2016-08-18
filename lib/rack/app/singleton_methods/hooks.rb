module Rack::App::SingletonMethods::Hooks

  def before(&block)
    @before_hooks ||= []
    @before_hooks << block unless block.nil?
    @before_hooks
  end

  def after(&block)
    @after_hooks ||= []
    @after_hooks << block unless block.nil?
    @after_hooks
  end

end
