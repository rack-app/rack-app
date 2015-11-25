api_class = Class.new(Rack::App)
Rack::App::Endpoint::NOT_FOUND = Rack::App::Endpoint.new(api_class) do
  response.status= 404
  response.write '404 Not Found'
  response.finish
end