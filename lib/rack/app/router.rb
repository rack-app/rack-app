class Rack::App::Router

  require 'rack/app/router/static'
  require 'rack/app/router/dynamic'

  #TD
  def endpoint_paths
    @static.endpoints.map do |indentifiers, endpoint|
      [[*indentifiers].join("\t"),endpoint.properties[:description]].compact.join("\t\t\t")
    end
  end

  def add_endpoint(request_method, request_path, endpoint)
    if defined_path_is_dynamic?(Rack::App::Utils.normalize_path(request_path))
      @dynamic.add_endpoint(request_method, request_path, endpoint)
    else
      @static.add_endpoint(request_method, request_path, endpoint)
    end
  end

  def fetch_endpoint(request_method, request_path)
    @static.fetch_endpoint(request_method, request_path) or
        @dynamic.fetch_endpoint(request_method, request_path) or
        Rack::App::Endpoint::NOT_FOUND
  end

  def merge!(router)
    raise(ArgumentError, "invalid router object, must be instance of #{self.class}") unless router.is_a?(self.class)
    @static.merge!(router.instance_variable_get(:@static))
    @dynamic.merge!(router.instance_variable_get(:@dynamic))
    nil
  end

  protected

  def initialize
    @static = Rack::App::Router::Static.new
    @dynamic = Rack::App::Router::Dynamic.new
  end

  def defined_path_is_dynamic?(path_str)
    !!(path_str.to_s =~ /\/:\w+/i)
  end

end
