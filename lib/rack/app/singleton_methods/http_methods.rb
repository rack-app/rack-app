module Rack::App::SingletonMethods::HttpMethods

  protected

  def get(path = '/', &block)
    add_route(::Rack::App::Constants::HTTP::GET, path, &block)
  end

  def post(path = '/', &block)
    add_route(::Rack::App::Constants::HTTP::POST, path, &block)
  end

  def put(path = '/', &block)
    add_route(::Rack::App::Constants::HTTP::PUT, path, &block)
  end

  def delete(path = '/', &block)
    add_route(::Rack::App::Constants::HTTP::DELETE, path, &block)
  end

  def head(path = '/', &block)
    add_route(::Rack::App::Constants::HTTP::HEAD, path, &block)
  end

  def options(path = '/', &block)
    add_route(::Rack::App::Constants::HTTP::OPTIONS, path, &block)
  end

  def patch(path = '/', &block)
    add_route(::Rack::App::Constants::HTTP::PATCH, path, &block)
  end

  def alias_endpoint(new_request_path, original_request_path)
    router.endpoints.select { |ep| ep[:request_path] == original_request_path }.each do |endpoint|
      router.register_endpoint!(endpoint[:request_method], new_request_path, endpoint[:description], endpoint[:endpoint])
    end
  end

end
