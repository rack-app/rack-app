class Rack::App::Router::Base

  def call(env)
    app = get_app(env)
    app && app.call(env)
  end

  def endpoints
    @endpoints ||= []
  end

  def register_endpoint!(endpoint)
    endpoints.push(endpoint)
    compile_endpoint!(endpoint)
    return endpoint
  end

  def reset
    clean_routes!
    compile_registered_endpoints!
  end

  protected

  def get_app(env)
    raise(NotImplementedError)
  end

  def compile_endpoint!(endpoint)
    raise(NotImplementedError)
  end

  def clean_routes!
    raise(NotImplementedError)
  end

  def compile_registered_endpoints!
    raise(NotImplementedError)
  end

  def fetch_context(request_method, request_path)
    raise(NotImplementedError)
  end

  def as_app(endpoint_or_app)
    if endpoint_or_app.respond_to?(:to_app)
      endpoint_or_app.to_app
    else
      endpoint_or_app
    end
  end

  def find_by_path_infos(env, &block)
    block.call(raw_path_info(env)) || block.call(formatted_path_info(env))
  end

  def get_request_method(env)
    env[::Rack::App::Constants::ENV::REQUEST_METHOD]
  end

  def raw_path_info(env)
    env[::Rack::App::Constants::ENV::PATH_INFO]
  end

  def formatted_path_info(env)
    path_info = raw_path_info(env).dup
    path_info.slice!(/#{Regexp.escape(extname(env))}$/)
    path_info
  end

  def extname(env)
    env[::Rack::App::Constants::ENV::EXTNAME]
  end

end
