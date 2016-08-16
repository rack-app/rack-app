module Rack::App::SingletonMethods::Middleware

  protected
  
  def middlewares(&block)
    @middlewares ||= []
    @middlewares << block unless block.nil?
    @middlewares
  end

  alias middleware middlewares

  def use(*args)
    middlewares{ |b| b.use(*args) }
  end

  def only_next_endpoint_middlewares(&block)
    @only_next_endpoint_middlewares ||= []
    @only_next_endpoint_middlewares << block unless block.nil?
    @only_next_endpoint_middlewares
  end

end