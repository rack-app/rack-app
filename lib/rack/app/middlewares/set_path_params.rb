class Rack::App::Middlewares::SetPathParams

  def initialize(app, build_env)
    @build_env = build_env
    @app = app
  end

  E = Rack::App::Constants::ENV

  def call(env)
    populate_path_params(env)
    correct_last_value_from_extensions(env)
    @app.call(env)
  end

  protected

  def populate_path_params(env)
    @build_env.params.each do |index, key|
      env[E::PATH_SEGMENTS_PARAMS][key] = env[E::SPLITTED_PATH_INFO][index]
    end
  end

  def correct_last_value_from_extensions(env)
    return if @build_env.endpoint.config.serializer.extnames.empty?
    last_index = env[E::SPLITTED_PATH_INFO].length - 1
    return if @build_env.params[last_index].nil?
    extless(env[E::PATH_SEGMENTS_PARAMS][@build_env.params[last_index]])
  end

  def extless(value)
    extname = File.extname(value)
    value.slice!(/#{Regexp.escape(extname)}$/) unless extname.empty?
  end

end
