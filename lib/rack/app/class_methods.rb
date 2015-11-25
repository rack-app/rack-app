module Rack::App::ClassMethods

  def description(*description_texts)
    @last_description = description_texts.join("\n")
  end

  def get(path = '/', &block)
    add_route('GET', path, &block)
  end

  def post(path = '/', &block)
    add_route('POST', path, &block)
  end

  def put(path = '/', &block)
    add_route('PUT', path, &block)
  end

  def head(path = '/', &block)
    add_route('HEAD', path, &block)
  end

  def delete(path = '/', &block)
    add_route('DELETE', path, &block)
  end

  def options(path = '/', &block)
    add_route('OPTIONS', path, &block)
  end

  def patch(path = '/', &block)
    add_route('PATCH', path, &block)
  end

  def router
    @static_router ||= Rack::App::Router.new
  end

  def add_route(request_method, request_path, &block)

    endpoint = Rack::App::Endpoint.new(
        self,
        {
            request_method: request_method,
            request_path: request_path,
            description: @last_description
        },
        &block
    )

    router.add_endpoint(request_method,request_path,endpoint)

    @last_description = nil
    endpoint
  end


  def mount(api_class)

    unless api_class.is_a?(Class) and api_class <= Rack::App
      raise(ArgumentError, 'Invalid class given for mount, must be a Rack::App')
    end

    router.merge!(api_class.router)

    nil
  end

end