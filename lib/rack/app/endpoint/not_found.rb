api_class = Class.new(Rack::APP)
Rack::APP::Endpoint::NOT_FOUND = Rack::APP::Endpoint.new(api_class) do
  response.status= 404
  response.write '404 Not Found'
  response.finish
end