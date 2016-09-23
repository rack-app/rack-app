module Rack::App::InstanceMethods::HTTPStatus

  def http_status!(code, desc=nil)
    raise unless code.is_a?(Integer)
    response.status = code
    response.write(desc || Rack::App::Constants::HTTP_STATUS_CODES[code] || raise)
    finish!
  end

end
