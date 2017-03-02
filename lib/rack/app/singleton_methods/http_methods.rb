module Rack::App::SingletonMethods::HttpMethods

  protected

  def get(path = '/', &block)
    add_route(::Rack::App::Constants::HTTP::METHOD::GET, path, Rack::App::Block.new(&block))
  end

  def post(path = '/', &block)
    add_route(::Rack::App::Constants::HTTP::METHOD::POST, path, Rack::App::Block.new(&block))
  end

  def put(path = '/', &block)
    add_route(::Rack::App::Constants::HTTP::METHOD::PUT, path, Rack::App::Block.new(&block))
  end

  def delete(path = '/', &block)
    add_route(::Rack::App::Constants::HTTP::METHOD::DELETE, path, Rack::App::Block.new(&block))
  end

  def head(path = '/', &block)
    add_route(::Rack::App::Constants::HTTP::METHOD::HEAD, path, Rack::App::Block.new(&block))
  end

  def options(path = '/', &block)
    add_route(::Rack::App::Constants::HTTP::METHOD::OPTIONS, path, Rack::App::Block.new(&block))
  end

  def patch(path = '/', &block)
    add_route(::Rack::App::Constants::HTTP::METHOD::PATCH, path, Rack::App::Block.new(&block))
  end

  def link(path = '/', &block)
    add_route(::Rack::App::Constants::HTTP::METHOD::LINK, path, Rack::App::Block.new(&block))
  end

  def unlink(path = '/', &block)
    add_route(::Rack::App::Constants::HTTP::METHOD::UNLINK, path, Rack::App::Block.new(&block))
  end

  def trace(path = '/', &block)
    add_route(::Rack::App::Constants::HTTP::METHOD::TRACE, path, Rack::App::Block.new(&block))
  end

  def alias_endpoint(new_request_path, original_request_path)
    new_request_path = Rack::App::Utils.normalize_path(new_request_path)
    original_request_path = Rack::App::Utils.normalize_path(original_request_path)

    router.endpoints.select { |ep| ep.request_path == original_request_path }.each do |endpoint|
      new_endpoint = endpoint.fork(:request_path => new_request_path)
      router.register_endpoint!(new_endpoint)
    end
  end

end
