module Rack::APP::Runner
  extend self

  def response_for(api_class, request_env)
    endpoint = fetch_endpoint(api_class,request_env['REQUEST_METHOD'],request_env['REQUEST_PATH'])
    endpoint.execute(request_env)
  end

  protected

  def fetch_endpoint(api_class, request_method, request_path)
    api_class.router.fetch_endpoint(request_method, request_path)
  end

end