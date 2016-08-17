class Rack::App::Router::Static < Rack::App::Router::Base

  def compile_registered_endpoints!
    mapped_endpoint_routes.clear
    endpoints.each do |endpoint|
      app = as_app(endpoint[:endpoint])
      mapped_endpoint_routes[[endpoint[:request_method].to_s.upcase, endpoint[:request_path]]]= app
    end
  end

  protected

  def fetch_context(request_method, request_path)
    app = mapped_endpoint_routes[[request_method, request_path]]
    app && {:app => app}
  end

  def mapped_endpoint_routes
    @mapped_endpoint_routes ||= {}
  end

end
