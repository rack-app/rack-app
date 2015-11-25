class Rack::App::Router

  require 'rack/app/router/static'
  require 'rack/app/router/dynamic'

  def add_endpoint(request_method, request_path, endpoint)
    if defined_path_is_dynamic?(Rack::App::Utils.normalize_path(request_path))
      @dynamic_router.add_endpoint(request_method, request_path, endpoint)
    else
      @static_router.add_endpoint(request_method, request_path, endpoint)
    end
  end

  def fetch_endpoint(request_method, request_path)
    @static_router.fetch_endpoint(request_method, request_path) or
        @dynamic_router.fetch_endpoint(request_method, request_path) or
        Rack::App::Endpoint::NOT_FOUND
  end

  def merge!(router)
    raise(ArgumentError, "invalid router object, must be instance of #{self.class}") unless router.is_a?(self.class)
    @static_router.merge!(router.instance_variable_get(:@static_router))
    @dynamic_router.merge!(router.instance_variable_get(:@dynamic_router))
    nil
  end

  protected

  def initialize
    @static_router = Rack::App::Router::Static.new
    @dynamic_router = Rack::App::Router::Dynamic.new
  end

  def defined_path_is_dynamic?(path_str)
    !!(path_str.to_s =~ /\/:\w+/i)
  end

end
