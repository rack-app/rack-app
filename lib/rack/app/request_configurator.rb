module Rack::App::RequestConfigurator

  extend self

  def configure(request_env)
    request_env[Rack::App::Constants::NORMALIZED_REQUEST_PATH]= Rack::App::Utils.normalize_path(request_env['REQUEST_PATH'])
    request_env
  end

end