module Rack::API::SyntaxSugar

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

  def add_route(request_method, request_path, &block)
    request_key = [request_method, request_path]

    endpoint = endpoints[request_key]= Rack::API::Endpoint.new(
        self,
        {
            request_method: request_method,
            request_path: request_path,
            description: @last_description
        },
        &block
    )

    @last_description = nil
    endpoint
  end

  def endpoints
    @endpoints ||= {}
  end

end