require "rack/response"
class Rack::App::Router::NotFound < Rack::App::Router::Base

  def fetch_context(request_method, path_info)
    {:app => lambda{|env| not_found_response }}
  end

  def fetch_endpoint(request_method, path_info)
    ::Rack::App::Endpoint::NOT_FOUND
  end

  protected

  def not_found_response
    rack_response = Rack::Response.new
    rack_response.status = 404
    rack_response.write('404 Not Found')
    rack_response.finish
  end
  
  def compile_registered_endpoints!
  end
end
