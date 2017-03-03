class Rack::App::Middlewares::Params::Setter

  def initialize(app)
    @app = app
  end

  def call(env)
    Rack::App::Params.new(env).to_hash

    @app.call(env)
  end

end
