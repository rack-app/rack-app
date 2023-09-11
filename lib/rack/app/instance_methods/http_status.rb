module Rack::App::InstanceMethods::HTTPStatus

  def http_status!(code, body=nil)
    raise unless code.is_a?(Integer)
    response.status = code
    respond_with(body || Rack::App::Constants::HTTP_STATUS_CODES[code] || raise)
  end

end
