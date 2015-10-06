require 'cgi'
class Rack::APP::RequestHelpers::Params

  def initialize(request_env, path_params_matcher={})
    @request_env = request_env

    @path_params_matcher = path_params_matcher

  end

  def to_hash
    query_params.merge(request_path_params)
  end

  protected

  def query_params
    CGI.parse(@request_env['QUERY_STRING'].to_s).freeze.reduce({}) do |params_collection, (k, v)|
      if v.is_a?(Array) and v.length === 1
        params_collection[k]= v[0]
      else
        k = k.sub(/\[\]$/,'')
        params_collection[k]= v
      end

      params_collection
    end
  end


  def request_path_params
    path_params = {}
    if @path_params_matcher.is_a?(Hash) and not @path_params_matcher.empty?

      request_path_parts = Rack::APP::Utils.normalize_path(@request_env['REQUEST_PATH']).split('/')

      path_params = request_path_parts.each.with_index.reduce({}) do |params_col, (path_part, index)|
        if @path_params_matcher[index]
          params_col[@path_params_matcher[index]]= path_part
        end
        params_col
      end

      path_params.merge!(path_params)

    end
    path_params
  end

end