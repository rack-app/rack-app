class Rack::App::Router

  require 'rack/app/router/static'
  require 'rack/app/router/dynamic'

  def show_endpoints
    endpoints = (@static.show_endpoints + @dynamic.show_endpoints)

    wd0 = endpoints.map { |row| row[0].to_s.length }.max
    wd1 = endpoints.map { |row| row[1].to_s.length }.max
    wd2 = endpoints.map { |row| row[2].to_s.length }.max

    return endpoints.map do |row|
      [
          row[0].to_s.ljust(wd0),
          row[1].to_s.ljust(wd1),
          row[2].to_s.ljust(wd2)
      ].join('   ')
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
    !!(path_str.to_s =~ /\/:\w+/i) or !!(path_str.to_s =~ /\/\*/i)
  end

end
