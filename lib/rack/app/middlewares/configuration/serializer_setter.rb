class Rack::App::Middlewares::Configuration::SerializerSetter

  def initialize(app, serializer)
    @app = app
    @serializer = serializer || raise
  end

  def call(env)
    # env[::Rack::App::Constants::ENV::EXTNAME] ||= extname(env)
    env[::Rack::App::Constants::ENV::SERIALIZER]= @serializer
    @app.call(env)
  end

  protected

  def extname(env)
    path_info = env[::Rack::App::Constants::ENV::PATH_INFO]
    File.extname(path_info.split("/").last.to_s)
  end

end
