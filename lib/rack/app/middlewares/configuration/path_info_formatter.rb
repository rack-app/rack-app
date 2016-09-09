class Rack::App::Middlewares::Configuration::PathInfoFormatter

  def initialize(app, cut_string_from_path)
    @cut_string_from_path = cut_string_from_path
    @app = app
  end

  def call(env)
    env[::Rack::App::Constants::ENV::ORIGINAL_PATH_INFO]= env[::Rack::App::Constants::ENV::PATH_INFO].dup
    env[::Rack::App::Constants::ENV::PATH_INFO].sub!(@cut_string_from_path, '')
    @app.call(env)
  end

end
