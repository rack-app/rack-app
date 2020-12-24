module Rack::App::InstanceMethods::ServeFile

  def serve_file(file_path)
    rack_resp = Rack::App::FileServer.serve_file(request.env, file_path)
    response.status = rack_resp[0]
    response.headers.merge!(rack_resp[1])
    response.body = rack_resp[2]
    finish!
  end

end
