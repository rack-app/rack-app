require 'cgi'
class Rack::App::Params

  def to_hash
    if @env[::Rack::App::Constants::ENV::PARSED_PARAMS]
      @env[::Rack::App::Constants::ENV::PARSED_PARAMS]
    else
      query_params.merge(request_path_params)
    end
  end

  protected

  def initialize(env)
    @env = env
  end

  def query_params
    raw_cgi_params.reduce({}) do |params_collection, (k, v)|
      k = k.sub(/\[\]$/, '')

      if single_paramter_value?(v)
        params_collection[k]= v[0]
      else
        params_collection[k]= v
      end

      params_collection
    end
  end

  def single_paramter_value?(v)
    v.is_a?(Array) and v.length === 1
  end

  def raw_cgi_params
    CGI.parse(@env[::Rack::QUERY_STRING].to_s)
  end

  def request_path_params
    path_params = {}
    path_params.merge!(extract_path_params) unless path_params_matcher.empty?
    path_params
  end

  def extract_path_params
    last_index = request_path_parts.length - 1
    request_path_parts.each.with_index.reduce({}) do |params_col, (path_part, index)|
      if path_params_matcher[index]
        if index == last_index && @env[::Rack::App::Constants::ENV::EXTNAME]
          matcher = Regexp.escape(@env[::Rack::App::Constants::ENV::EXTNAME])
          path_part = path_part.sub(/#{matcher}$/,'')
        end
        params_col[path_params_matcher[index]]= path_part
      end

      params_col
    end
  end

  def request_path_parts
    @env[::Rack::App::Constants::ENV::PATH_INFO].split('/')
  end

  def path_params_matcher
    @env[::Rack::App::Constants::ENV::PATH_PARAMS_MATCHER] || {}
  end

end
