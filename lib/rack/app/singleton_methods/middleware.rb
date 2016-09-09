module Rack::App::SingletonMethods::Middleware

  def middlewares(&block)
    @middlewares ||= []
    unless block.nil?
      @middlewares << block
      router.reset
    end
    @middlewares
  end

  alias middleware middlewares

  def use(*args)
    middlewares{ |b| b.use(*args) }
  end

  protected

  def next_endpoint_middlewares(&block)
    @next_endpoint_middlewares ||= []
    @next_endpoint_middlewares << block unless block.nil?
    @next_endpoint_middlewares
  end

  alias only_next_endpoint_middlewares next_endpoint_middlewares

  Rack::App::Utils.deprecate(self,
    :only_next_endpoint_middlewares,
    :next_endpoint_middlewares,
    2016,9
  )

end
