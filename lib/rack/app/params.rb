require 'cgi'
class Rack::App::Params

  def to_hash
    if @request_env[::Rack::App::Constants::ENV::PARSED_PARAMS]
      @request_env[::Rack::App::Constants::ENV::PARSED_PARAMS]
    else
      query_params.merge(request_path_params)
    end
  end

  protected

  def initialize(request_env)
    @request_env = request_env
  end

  def query_params
    raw_cgi_params.reduce({}) do |params_collection, (k, v)|

      if single_paramter_value?(v)
        params_collection[k]= v[0]

      else
        k = k.sub(/\[\]$/, '')
        params_collection[k]= v

      end

      params_collection

    end
  end

  def single_paramter_value?(v)
    v.is_a?(Array) and v.length === 1
  end

  def raw_cgi_params
    CGI.parse(@request_env[::Rack::QUERY_STRING].to_s)
  end

  def request_path_params
    path_params = {}
    path_params.merge!(extract_path_params) unless path_params_matcher.empty?
    path_params
  end

  def extract_path_params
    request_path_parts.each.with_index.reduce({}) do |params_col, (path_part, index)|
      params_col[path_params_matcher[index]]= path_part if path_params_matcher[index]
      params_col
    end
  end

  def request_path_parts
    @request_env[::Rack::PATH_INFO].split('/')
  end

  def path_params_matcher
    @request_env[::Rack::App::Constants::ENV::PATH_PARAMS_MATCHER] || {}
  end

end
