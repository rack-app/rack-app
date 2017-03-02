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

  def add_route(request_method, request_path, callable)

    router.register_endpoint!(
      Rack::App::Endpoint.new({
        :app_class => self,
        :callable => callable,
        :payload => payload,
        :error_handler => error,
        :request_methods => [request_method],
        :route => route_registration_properties.dup,
        :endpoint_specific_middlewares => next_endpoint_middlewares.dup,
        :request_path => ::Rack::App::Utils.join(@namespaces, request_path)
      })
    )

    next_endpoint_middlewares.clear
    route_registration_properties.clear
    return nil

  end

  def add_app_to_route(app, request_path)
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
