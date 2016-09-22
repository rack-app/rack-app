module Rack::App::SingletonMethods::RackInterface

  public

  def call(env)
    return router.call(env)
  end

end
