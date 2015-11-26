require 'cgi'
class Rack::App::RequestHelpers::Params

  def initialize(request_env)
    @request_env = request_env
  end

  def to_hash
    query_params.merge(request_path_params)
  end

  protected

  def query_params
    CGI.parse(@request_env[Rack::QUERY_STRING].to_s).freeze.reduce({}) do |params_collection, (k, v)|

      if v.is_a?(Array) and v.length === 1
        params_collection[k]= v[0]
      else
        k = k.sub(/\[\]$/, '')
        params_collection[k]= v
      end

      params_collection

    end
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
    Rack::App::Utils.normalize_path(@request_env['REQUEST_PATH']).split('/')
  end

  def path_params_matcher
    @request_env['rack.app.path_params_matcher'] || {}
  end

end