class Rack::App::Middlewares::Configuration::PathParamsMatcher

  def initialize(app, path_params)
    @path_params = path_params
    @app = app
  end

  def call(env)
    env[::Rack::App::Constants::ENV::PATH_PARAMS_MATCHER]= @path_params.dup

    @app.call(env)
  end

end
