class Rack::App::Router::Base

  def call(env)

    request_method= env[Rack::REQUEST_METHOD]
    path_info= env[Rack::PATH_INFO]

    context = fetch_context(request_method, path_info)
    return unless context.is_a?(Hash) and not context[:app].nil?

    format_env(context, env)
    context[:app].call(env)

  end

  def format_env(context, env)
  end

  def endpoints
    @endpoints ||= []
  end

  def register_endpoint!(request_method, request_path, endpoint, properties={})
    endpoints.push(
        {
            :request_method => request_method,
            :request_path => Rack::App::Utils.normalize_path(request_path),
            :endpoint => endpoint,
            :properties => properties
        }
    )

    reset
    return endpoint
  end

  def reset
    clean_routes!
    compile_registered_endpoints!
  end

  protected

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
