module Rack::App::SingletonMethods::RackInterface

  public

  def call(request_env)
    Rack::App::RequestConfigurator.configure(request_env)
    endpoint = router.fetch_endpoint(
        request_env[::Rack::REQUEST_METHOD],
        request_env[Rack::App::Constants::NORMALIZED_PATH_INFO])
    endpoint.call(request_env)
  end

end
