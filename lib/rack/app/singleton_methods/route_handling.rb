module Rack::App::SingletonMethods::RouteHandling

  def router
    @router ||= Rack::App::Router.new
  end

  protected

  def root(endpoint_path)
    alias_endpoint('/', endpoint_path)
  end

  def route_registration_properties
    @route_registration_properties ||= {}
  end

  def description(*description_texts)
    route_registration_properties[:description]= description_texts.join("\n")
  end

  alias desc description

  def add_route(request_method, request_path, &block)

    request_path = ::Rack::App::Utils.join(@namespaces, request_path)

    properties = {
        :user_defined_logic => block,
        :request_method => request_method,
        :request_path => request_path,
        :error_handler => error,
        :serializer => serializer,
        :middleware_builders_blocks => only_next_endpoint_middlewares.dup,
        :app_class => self
    }

    only_next_endpoint_middlewares.clear

    endpoint = Rack::App::Endpoint.new(properties)
    router.register_endpoint!(request_method, request_path, endpoint, route_registration_properties)
    @route_registration_properties = nil
    return endpoint

  end

  def namespace(request_path_namespace)
    return unless block_given?
    @namespaces ||= []
    @namespaces.push(request_path_namespace)
    yield
  ensure
    @namespaces.pop
  end

end
