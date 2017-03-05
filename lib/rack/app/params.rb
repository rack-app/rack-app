require 'cgi'
require 'uri'
class Rack::App::Params

  E = ::Rack::App::Constants::ENV

  def to_hash
    @env[E::MERGED_PARAMS] ||= query_string_params.merge(path_segments_params)
  end

  def query_string_params
    @env[E::QUERY_STRING_PARAMS] ||= generate_query_params
  end

  def path_segments_params
    @env[E::PATH_SEGMENTS_PARAMS]
  end

  def validated_params
    @env[E::VALIDATED_PARAMS]
  end

  protected

  def initialize(env)
    @env = env
  end

  def generate_query_params
    raw_cgi_params.reduce({}) do |params_collection, (k, v)|
      params_collection[k.sub(/\[\]$/, '')] = formatted_value(k, v)
      params_collection
    end
  end

  def formatted_value(key, value)
    single_paramter_value?(value) && !key.end_with?("[]") ? value[0] : value
  end

  def single_paramter_value?(v)
    v.is_a?(Array) and v.length === 1
  end

  def raw_cgi_params
    CGI.parse(@env[::Rack::QUERY_STRING].to_s)
  end

end
