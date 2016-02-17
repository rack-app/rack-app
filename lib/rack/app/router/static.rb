class Rack::App::Router::Static < Rack::App::Router::Base

  def fetch_endpoint(request_method, request_path)
    mapped_endpoint_routes[[request_method, request_path]]
  end

  def compile_registered_endpoints!
    mapped_endpoint_routes.clear
    endpoints.each do |endpoint|
      request_method, request_path, endpoint_object = endpoint[:request_method], endpoint[:request_path], endpoint[:endpoint]
      mapped_endpoint_routes[[request_method.to_s.upcase, request_path]]= endpoint_object
    end
  end

  protected

  def mapped_endpoint_routes
    @mapped_endpoint_routes ||= {}
  end

end