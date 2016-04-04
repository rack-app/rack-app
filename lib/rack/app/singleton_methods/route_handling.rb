module Rack::App::SingletonMethods::RouteHandling

  def router
    @router ||= Rack::App::Router.new
  end

  protected

  def root(endpoint_path)
    alias_endpoint '/', endpoint_path
  end

  def description(*description_texts)
    @last_description = description_texts.join("\n")
  end

  alias desc description

  def add_route(request_method, request_path, &block)

    request_path = ::Rack::App::Utils.join(@namespaces, request_path)

    builder = Rack::Builder.new
    middlewares.each do |builder_block|
      builder_block.call(builder)
    end

    properties = {
        :user_defined_logic => block,
        :request_method => request_method,
        :request_path => request_path,

        :error_handler => error,
        :description => @last_description,
        :serializer => serializer,
        :middleware => builder,
        :app_class => self
    }


    endpoint = Rack::App::Endpoint.new(properties)
    router.register_endpoint!(request_method, request_path, @last_description, endpoint)

    @last_description = nil
    return endpoint

  end

  def namespace(request_path_namespace)
    return unless block_given?
    @namespaces ||= []
    @namespaces.push(request_path_namespace)
    yield
    @namespaces.pop
    nil
  end

end