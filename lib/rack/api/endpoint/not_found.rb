api_class = Class.new(Rack::API)
Rack::API::Endpoint::NOT_FOUND = Rack::API::Endpoint.new(api_class) do
  response.status= 404
  response.write '404 Not Found'
  response.finish
end