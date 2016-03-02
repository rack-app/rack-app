module Rack::App::InstanceMethods::Upload

  def serve_file(file_path)
    raw_rack_resp = Rack::App::FileServer.serve_file(request.env, file_path)
    response.headers.merge!(raw_rack_resp[1])
    response.body = raw_rack_resp.last
    return nil
  end

end

