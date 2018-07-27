# frozen_string_literal: true
class Rack::App::Router::Tree::Vein < ::Hash

  def set(env)
    app = create_app(env)
    request_methods(env).each do |request_method|
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
    env.params.empty? ? app : wrap(app, env)
  end

  def wrap(app, env)
    builder = Rack::Builder.new
    builder.use(Rack::App::Middlewares::SetPathParams, env)
    builder.run(app)
    builder.to_app
  end

  def request_methods(env)
    request_method = env.endpoint.request_method
    case request_method || raise('missing config: request_methods')
    when Rack::App::Constants::HTTP::METHOD::ANY
      Rack::App::Constants::HTTP::METHODS
    else
      [request_method].flatten.map(&:to_sym)
    end
  end

end
