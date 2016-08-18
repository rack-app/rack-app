class Rack::App::Middlewares::Hooks::Before

  def initialize(app, hook_block)
    @app = app
    @hook_block = hook_block
  end

  def call(env)
    env[Rack::App::Constants::ENV::REQUEST_HANDLER].instance_exec(&@hook_block)
    @app.call(env)
  end

end
