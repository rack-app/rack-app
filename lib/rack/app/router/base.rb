class Rack::App::Router::Base

  def endpoints
    @endpoints ||= []
  end

  def register_endpoint!(request_method, request_path, description, endpoint)
    endpoints.push(
        {
            :request_method => request_method,
            :request_path => Rack::App::Utils.normalize_path(request_path),
            :description => description,
            :endpoint => endpoint
        }
    )

    compile_registered_endpoints!
    return endpoint
  end

  def fetch_endpoint(request_method, request_path)
    raise('IMPLEMENTATION MISSING ERROR')
  end

  protected

  def compile_registered_endpoints!
    raise('IMPLEMENTATION MISSING ERROR')
  end

end