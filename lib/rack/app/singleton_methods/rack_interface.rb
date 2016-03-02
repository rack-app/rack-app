module Rack::App::SingletonMethods::RackInterface

  def call(request_env)
    Rack::App::RequestConfigurator.configure(request_env)
    endpoint = router.fetch_endpoint(
        request_env['REQUEST_METHOD'],
        request_env[Rack::App::Constants::NORMALIZED_REQUEST_PATH])
    endpoint.call(request_env)
  end

end
