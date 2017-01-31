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
      stripped_key = k.sub(/\[\]$/, '')

      if single_paramter_value?(v) && !k.end_with?("[]")
        params_collection[stripped_key]= v[0]
      else
        params_collection[stripped_key]= v
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
    @env[::Rack::App::Constants::ENV::PATH_PARAMS]
  end

end
