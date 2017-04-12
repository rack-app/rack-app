class Rack::App::Endpoint::Catcher

  def initialize(app, endpoint_properties)
    @app = app
    @endpoint_properties = endpoint_properties
  end

  def call(env)
    handle_rack_response do
      handle_response_body(env) do
        @app.call(env)
      end
    end
  end

  protected

  def handle_rack_response
    catch(:rack_response) { return yield }.finish
  end

  def handle_response_body(env)
    body = catch(:response_body) { return yield }
    request_handler = env[Rack::App::Constants::ENV::HANDLER]
    set_response_body(request_handler, body)
    throw :rack_response, request_handler.response
  end

  EXTNAME = ::Rack::App::Constants::ENV::EXTNAME

  def set_response_body(handler, response_body)
    extname = handler.request.env[EXTNAME]
    handler.response.headers.merge!(@endpoint_properties.serializer.response_headers_for(extname))
    handler.response.write(@endpoint_properties.serializer.serialize(extname, response_body))
  end

end
