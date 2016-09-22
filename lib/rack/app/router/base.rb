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

end
