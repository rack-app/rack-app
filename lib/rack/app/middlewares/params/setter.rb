class Rack::App::Middlewares::Params::Setter

  def initialize(app)
    @app = app
  end

  def call(env)
    env[::Rack::App::Constants::PARSED_PARAMS] ||= params_hash(env)

    @app.call(env)
  end

  protected

  def params_hash(env)
    Rack::App::Params.new(env).to_hash
  end

end
