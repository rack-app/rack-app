module Rack::App::RequestConfigurator

  extend self

  def configure(env)
    path_info(env)
    env
  end

  protected

  def path_info(env)
    path_info = env[::Rack::App::Constants::ENV::PATH_INFO]
    env[::Rack::App::Constants::ENV::ORIGINAL_PATH_INFO]= path_info
    env[::Rack::App::Constants::ENV::PATH_INFO]= Rack::App::Utils.normalize_path(path_info)
  end

end