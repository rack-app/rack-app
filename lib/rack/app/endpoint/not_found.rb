app_class = Class.new(Rack::App)
not_found_properties = {
    :user_defined_logic => lambda {
      response.status= 404
      return '404 Not Found'
    },
    :default_headers => {},
    :request_method => 'GET',
    :error_handler => Rack::App::ErrorHandler.new,
    :request_path => '\404',
    :description => 'page not found',
    :serializer => Rack::App::Serializer.new,
    :app_class => app_class
}

Rack::App::Endpoint::NOT_FOUND = Rack::App::Endpoint.new(not_found_properties)