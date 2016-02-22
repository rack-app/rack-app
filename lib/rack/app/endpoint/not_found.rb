app_class = Class.new(Rack::App)
not_found_properties = {
    :user_defined_logic => lambda {
      response.status= 404
      return '404 Not Found'
    },
    :request_method => 'GET',
    :request_path => '\404',
    :description => 'page not found',
    :app_class => app_class
}

Rack::App::Endpoint::NOT_FOUND = Rack::App::Endpoint.new(not_found_properties)