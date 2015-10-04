require 'cgi'
module Rack::APP::RequestHelpers

  def params
    @__request_params__ ||= -> {

      raw_params = CGI.parse(request.env['QUERY_STRING'].to_s).freeze.reduce({}) do |params_collection, (k, v)|
        if v.is_a?(Array) and v.length === 1
          params_collection[k]= v[0]
        else
          params_collection[k]= v
        end

        params_collection
      end

      if @options[:path_params_matcher].is_a?(Hash) and not @options[:path_params_matcher].empty?

        request_path_parts = Rack::APP::Utils.normalize_path(request.env['REQUEST_PATH']).split('/')

        path_params = request_path_parts.each.with_index.reduce({}) do |params_col,(path_part,index)|
          if @options[:path_params_matcher][index]
            params_col[@options[:path_params_matcher][index]]= path_part
          end
          params_col
        end

        raw_params.merge!(path_params)

      end

      raw_params

    }.call
  end

  def status(new_status=nil)
    response.status= new_status.to_i unless new_status.nil?

    response.status
  end

end