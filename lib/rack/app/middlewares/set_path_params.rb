class Rack::App::Middlewares::SetPathParams

  def initialize(app, params_lookup_hash)
    @params_lookup_hash = params_lookup_hash
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
    @params_lookup_hash.each do |index, key|
      env[E::PATH_SEGMENTS_PARAMS][key] = env[E::SPLITTED_PATH_INFO][index]
    end
  end

  def correct_last_value_from_extensions(env)
    last_index = env[E::SPLITTED_PATH_INFO].length - 1
    return if @params_lookup_hash[last_index].nil?
    extless(env[E::PATH_SEGMENTS_PARAMS][@params_lookup_hash[last_index]])
  end

  def extless(value)
    extname = File.extname(value)
    value.slice!(/#{Regexp.escape(extname)}$/) unless extname.empty?
  end

end
