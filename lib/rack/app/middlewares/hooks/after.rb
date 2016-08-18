class Rack::App::Middlewares::Hooks::After

  def initialize(app, hook_block)
    @app = app
    @hook_block = hook_block
  end

  def call(env)
    response = @app.call(env)
    env[Rack::App::Constants::ENV::REQUEST_HANDLER].instance_exec(&@hook_block)
    return response
  end

end
