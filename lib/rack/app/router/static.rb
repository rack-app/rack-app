class Rack::App::Router::Static

  def add_endpoint(request_method, request_path, endpoint)
    @endpoints[[request_method.to_s.upcase, Rack::App::Utils.normalize_path(request_path)]]= endpoint
  end

  def fetch_endpoint(request_method, request_path)
    @endpoints[[request_method, request_path]]
  end

  def merge!(static_router)
    raise(ArgumentError,"Invalid argument given, must be instance of a #{self.class.to_s}") unless static_router.is_a?(self.class)
    @endpoints.merge!(static_router.instance_variable_get(:@endpoints))
    nil
  end

  protected

  def initialize
    @endpoints = {}
  end

end