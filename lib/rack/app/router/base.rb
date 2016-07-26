class Rack::App::Router::Base

  def call(env)

    request_method= env[Rack::REQUEST_METHOD]
    path_info= env[Rack::PATH_INFO]

    context = fetch_context(request_method, path_info)
    return unless context.is_a?(Hash) and not context[:endpoint].nil?

    format_env(context, env)
    context[:endpoint].call(env)

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

    compile_registered_endpoints!
    return endpoint
  end

  protected

  def fetch_context(request_method, request_path)
    raise('IMPLEMENTATION MISSING ERROR')
  end

  def compile_registered_endpoints!
    raise('IMPLEMENTATION MISSING ERROR')
  end

end
