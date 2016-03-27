class Rack::App::Router::NotFound < Rack::App::Router::Base

  def fetch_context(request_method, path_info)
    {:endpoint => ::Rack::App::Endpoint::NOT_FOUND}
  end

  def fetch_endpoint(request_method, path_info)
    ::Rack::App::Endpoint::NOT_FOUND
  end

end