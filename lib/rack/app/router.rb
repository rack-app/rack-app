class Rack::App::Router

  require 'rack/app/router/base'
  require 'rack/app/router/static'
  require 'rack/app/router/dynamic'
  require 'rack/app/router/not_found'

  def call(env)
    response = nil
    registered_endpoint_routers.find do |router|
      response = router.call(env)
    end
    return response
  end

  def endpoints
    registered_endpoint_routers.map(&:endpoints).reduce([],:+)
  end

  def show_endpoints

    endpoints = self.endpoints

    wd0 = endpoints.map { |endpoint| endpoint[:request_method].to_s.length }.max
    wd1 = endpoints.map { |endpoint| endpoint[:request_path].to_s.length }.max
    wd2 = endpoints.map { |endpoint| endpoint[:description].to_s.length }.max

    return endpoints.sort_by { |endpoint| [endpoint[:request_method], endpoint[:request_path]] }.map do |endpoint|
      [
          endpoint[:request_method].to_s.ljust(wd0),
          endpoint[:request_path].to_s.ljust(wd1),
          endpoint[:description].to_s.ljust(wd2)
      ].join('   ')
    end

  end

  def register_endpoint!(request_method, request_path, description, endpoint)
    router = router_for(request_path)
    router.register_endpoint!(request_method, request_path, description, endpoint)
  end

  def merge_router!(router, prop={})
    raise(ArgumentError, 'invalid router object, must implement :endpoints interface') unless router.respond_to?(:endpoints)
    router.endpoints.each do |endpoint|
      request_path = ::Rack::App::Utils.join(prop[:namespaces], endpoint[:request_path])

      register_endpoint!(
          endpoint[:request_method],
          request_path,
          endpoint[:description],
          endpoint[:endpoint]
      )
    end
    nil
  end

  protected

  def initialize
    @static = Rack::App::Router::Static.new
    @dynamic = Rack::App::Router::Dynamic.new
    @not_found = Rack::App::Router::NotFound.new
  end

  def registered_endpoint_routers
    [@static, @dynamic, @not_found]
  end

  def router_for(request_path)
    defined_path_is_dynamic?(request_path) ? @dynamic : @static
  end

  def defined_path_is_dynamic?(path_str)
    path_str = Rack::App::Utils.normalize_path(path_str)
    !!(path_str.to_s =~ /\/:\w+/i) or
        !!(path_str.to_s =~ /\/\*/i) or
        path_str.include?(Rack::App::Constants::RACK_BASED_APPLICATION)
  end

end
