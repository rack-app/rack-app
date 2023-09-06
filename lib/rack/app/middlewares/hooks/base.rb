class Rack::App::Middlewares::Hooks::Base

  def initialize(app, hook)
    @app = app
    @hook = hook
  end

  def call(env)
    raise(NotImplementedError)
  end

  protected

  def execute_hook(env)
    catch :rack_response do
      @hook.exec(env)
      nil
    end
  end

end
