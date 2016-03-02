module Rack::App::InstanceMethods::HttpControl

  def redirect_to(url)
    url = "#{url}?#{request.env['QUERY_STRING']}" unless request.env['QUERY_STRING'].empty?
    response.status = 301
    response.headers.merge!({'Location' => url})
    'See Ya!'
  end

end

