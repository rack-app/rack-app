module Rack::App::SingletonMethods::RackInterface

  public

  def call(env)
    Rack::App::RequestConfigurator.configure(env)
    return router.call(env)
  end

end
