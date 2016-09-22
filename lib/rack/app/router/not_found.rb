require "rack/response"
class Rack::App::Router::NotFound < Rack::App::Router::Base

  protected

  NOT_FOUND_APP = lambda do |env|
    rack_response = Rack::Response.new
    rack_response.status = 404
    rack_response.write('404 Not Found')
    rack_response.finish
  end

  def get_app(env)
    NOT_FOUND_APP
  end

  def compile_registered_endpoints!
  end
end
