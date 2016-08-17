module Rack::App::SingletonMethods::HttpMethods

  protected

  def get(path = '/', &block)
    add_route(::Rack::App::Constants::HTTP::METHOD::GET, path, &block)
  end

  def post(path = '/', &block)
    add_route(::Rack::App::Constants::HTTP::METHOD::POST, path, &block)
  end

  def put(path = '/', &block)
    add_route(::Rack::App::Constants::HTTP::METHOD::PUT, path, &block)
  end

  def delete(path = '/', &block)
    add_route(::Rack::App::Constants::HTTP::METHOD::DELETE, path, &block)
  end

  def head(path = '/', &block)
    add_route(::Rack::App::Constants::HTTP::METHOD::HEAD, path, &block)
  end

  def options(path = '/', &block)
    add_route(::Rack::App::Constants::HTTP::METHOD::OPTIONS, path, &block)
  end

  def patch(path = '/', &block)
    add_route(::Rack::App::Constants::HTTP::METHOD::PATCH, path, &block)
  end

  def link(path = '/', &block)
    add_route(::Rack::App::Constants::HTTP::METHOD::LINK, path, &block)
  end
  
  def unlink(path = '/', &block)
    add_route(::Rack::App::Constants::HTTP::METHOD::UNLINK, path, &block)
  end

  def trace(path = '/', &block)
    add_route(::Rack::App::Constants::HTTP::METHOD::TRACE, path, &block)
  end

  def alias_endpoint(new_request_path, original_request_path)
    new_request_path = Rack::App::Utils.normalize_path(new_request_path)
    original_request_path = Rack::App::Utils.normalize_path(original_request_path)

    router.endpoints.select { |ep| ep[:request_path] == original_request_path }.each do |endpoint|
      router.register_endpoint!(
        endpoint[:request_method], new_request_path,
        endpoint[:endpoint], endpoint[:properties]
      )
    end
  end

end
