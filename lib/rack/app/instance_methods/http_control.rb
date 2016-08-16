module Rack::App::InstanceMethods::HttpControl

  def redirect_to(url, params={})

    if params.empty?
      url = [url, request.env['QUERY_STRING']].join('?') unless request.env['QUERY_STRING'].empty?
    else
      query_string = Rack::App::Utils.encode_www_form(params.to_a)
      url = [url, query_string].join('?')
    end

    response.status = 301
    response.headers.merge!({'Location' => url})

    finish_response
    
  end

end
