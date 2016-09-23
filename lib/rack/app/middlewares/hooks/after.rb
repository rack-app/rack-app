class Rack::App::Middlewares::Hooks::After < Rack::App::Middlewares::Hooks::Base
  def call(env)
    response = @app.call(env)
    
    return execute_hook(env) || response
  end
end
