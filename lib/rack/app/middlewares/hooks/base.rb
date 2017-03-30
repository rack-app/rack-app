class Rack::App::Middlewares::Hooks::Base

  def initialize(app, hook_block)
    @app = app
    @hook_block = hook_block
  end

  def call(env)
    raise(NotImplementedError)
  end

  protected

  def execute_hook(env)
    catch :rack_response do
      env[Rack::App::Constants::ENV::HANDLER].instance_exec(&@hook_block)
      nil
    end
  end

end
