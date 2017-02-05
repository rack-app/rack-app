# frozen_string_literal: true
class Rack::App::Router::Tree::Vein < ::Hash

  def set(env)
    app = create_app(env)
    env.endpoint.request_methods.each do |request_method|
      self[request_method.to_s.upcase] = app
    end
  end

  def call(env)
    app = app_by(env)
    app && app.call(env)
  end

  protected

  def app_by(env)
    self[env[Rack::App::Constants::ENV::REQUEST_METHOD]]
  end

  def create_app(env)
    app = env.endpoint.to_app
    env.params.empty? ? app : wrap(app, env.params)
  end

  def wrap(app, params)
    builder = Rack::Builder.new
    builder.use(Rack::App::Middlewares::SetPathParams, params)
    builder.run(app)
    builder.to_app
  end

end
