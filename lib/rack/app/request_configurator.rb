module Rack::App::RequestConfigurator

  extend self

  def configure(request_env)
    request_env[Rack::App::Constants::NORMALIZED_PATH_INFO]= Rack::App::Utils.normalize_path(request_env[::Rack::PATH_INFO])
    request_env
  end

end