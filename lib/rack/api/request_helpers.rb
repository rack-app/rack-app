require 'cgi'
module Rack::API::RequestHelpers

  def params
    @__request_params__ ||= CGI.parse(request.env['QUERY_STRING']).freeze.reduce({}) do |params_collection, (k, v)|
      if v.is_a?(Array) and v.length === 1
        params_collection[k]= v[0]
      else
        params_collection[k]= v
      end

      params_collection
    end
  end

end