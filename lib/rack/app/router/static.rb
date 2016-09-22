class Rack::App::Router::Static < Rack::App::Router::Base

  protected

  def get_app(env)
    request_method= env[::Rack::App::Constants::ENV::REQUEST_METHOD]
    path_info= env[Rack::App::Constants::ENV::PATH_INFO]
    mapped_endpoint_routes[[request_method, path_info]]
  end

  def mapped_endpoint_routes
    @mapped_endpoint_routes ||= {}
  end

  def clean_routes!
    mapped_endpoint_routes.clear
  end

  def compile_endpoint!(endpoint)
    endpoint.supported_extnames.map do |extname|
      endpoint.request_path + extname

    end.push(endpoint.request_path).each do |request_path|
      routing_key = [endpoint.request_method, request_path]

      mapped_endpoint_routes[routing_key]= as_app(endpoint)
    end
  end

  def compile_registered_endpoints!
    endpoints.each do |endpoint|
      compile_endpoint!(endpoint)
    end
  end

end
