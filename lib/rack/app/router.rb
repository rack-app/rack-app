class Rack::App::Router

  require 'rack/app/router/tree'

  attr_reader :tree

  NOT_FOUND_APP = lambda do |env|
    rack_response = Rack::Response.new
    rack_response.status = 404
    rack_response.write('404 Not Found')
    rack_response.finish
  end

  def call(env)
    env[Rack::App::Constants::ENV::ROUTER]= self
    @tree.call(env) || NOT_FOUND_APP.call(env)
  end

  def endpoints
    @endpoints ||= []
  end

  def register_endpoint!(endpoint)
    endpoints.push(endpoint)
    compile_endpoint!(endpoint)
    return endpoint
  end

  # add ! to method name
  def reset
    @lookup_paths = Hash.new #(Hash.new)
    @tree = Rack::App::Router::Tree.new
    compile_registered_endpoints!
  end

  # rename to merge!
  def merge_router!(router, prop={})
    raise(ArgumentError, 'invalid router object, must implement :endpoints interface') unless router.respond_to?(:endpoints)
    router.endpoints.each do |endpoint|
      new_request_path = ::Rack::App::Utils.join(prop[:namespaces], endpoint.request_path)
      new_endpoint = endpoint.fork(:request_path => new_request_path)
      register_endpoint!(new_endpoint)
    end
    nil
  end


  def show_endpoints

    endpoints = self.endpoints

    wd0 = endpoints.map { |endpoint| endpoint.request_method.to_s.length }.max
    wd1 = endpoints.map { |endpoint| endpoint.request_path.to_s.length }.max
    wd2 = endpoints.map { |endpoint| endpoint.description.to_s.length }.max

    return endpoints.sort_by { |endpoint| [endpoint.request_method, endpoint.request_path] }.map do |endpoint|
      [
        endpoint.request_method.to_s.ljust(wd0),
        endpoint.request_path.to_s.ljust(wd1),
        endpoint.description.to_s.ljust(wd2)
      ].join('   ')
    end

  end

  def path_to(klass, defined_path)
    (@lookup_paths[klass][defined_path] || raise("missing path reference: #{klass}/#{original_path}")).dup
  end

  protected

  def initialize
    reset
  end

  def compile_registered_endpoints!
    endpoints.each do |endpoint|
      compile_endpoint!(endpoint)
    end
  end

  def compile_endpoint!(endpoint)
    @tree.add(endpoint)
    add_to_lookup_paths(endpoint)
  end

  def add_to_lookup_paths(endpoint)
    return unless endpoint.rack_app?
    def_path = endpoint.config.defined_request_path
    final_path = endpoint.request_path
    dictionary = @lookup_paths[endpoint.config.app_class] ||= {}
    dictionary[def_path]= final_path
  end

end
