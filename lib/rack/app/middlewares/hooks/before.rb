class Rack::App::Middlewares::Hooks::Before < Rack::App::Middlewares::Hooks::Base
  def call(env)
    execute_hook(env) || @app.call(env)
  end
end
