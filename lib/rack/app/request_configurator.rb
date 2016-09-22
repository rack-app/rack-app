module Rack::App::RequestConfigurator

  extend self

  def configure(env)
    path_info(env)
    env
  end

  protected

  EXTNAME = ::Rack::App::Constants::ENV::EXTNAME
  PATH_INFO = ::Rack::App::Constants::ENV::PATH_INFO
  ORIGINAL_PATH_INFO = ::Rack::App::Constants::ENV::ORIGINAL_PATH_INFO

  def path_info(env)
    path_info = env[PATH_INFO]
    env[ORIGINAL_PATH_INFO]= path_info.dup
    env[PATH_INFO]= Rack::App::Utils.normalize_path(path_info)
  end

end
