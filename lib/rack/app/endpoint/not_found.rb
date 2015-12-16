app_class = Class.new(Rack::App)
not_found_properties = {
    :user_defined_logic => lambda {
      response.status= 404
      response.write '404 Not Found'
      response.finish
    },
    :request_method => 'GET',
    :request_path => '\404',
    :description => 'page not found',
    :serializer => lambda { |o| String(o) },
    :app_class => app_class
}

Rack::App::Endpoint::NOT_FOUND = Rack::App::Endpoint.new(not_found_properties)