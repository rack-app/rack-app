module Rack::App::InstanceMethods::RedirectTo

  def redirect_to(url, params={})

    if params.empty?
      url = [url, request.env['QUERY_STRING']].join('?') unless request.env['QUERY_STRING'].empty?
    else
      query_string = Rack::Utils.build_nested_query(params)
      url = [url, query_string].join('?')
    end

    response.status = 301
    response.headers['Location']= url

    finish!

  end

end
