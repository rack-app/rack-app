module Rack::App::InstanceMethods::ServeFile

  def serve_file(file_path)
    raw_rack_resp = Rack::App::FileServer.serve_file(request.env, file_path)
    response.status = raw_rack_resp[0]
    response.headers.merge!(raw_rack_resp[1])
    response.body = raw_rack_resp[2]
    finish!
  end

end
