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
    raw_rack_formatted_params.reduce({}) do |params_collection, (k, v)|
      params_collection[k.sub(/\[\]$/, '')] = v
      params_collection
    end
  end

  def single_paramter_value?(v)
    v.is_a?(Array) && v.length === 1
  end

  def formatted_value(key, value)
    single_paramter_value?(value) && !key.end_with?('[]') ? value[0] : value
  end

  def query_string
    @env[::Rack::QUERY_STRING]
  end

  def raw_rack_formatted_params
    ::Rack::Utils.parse_nested_query(query_string).merge!(params_that_presented_multiple_times)
  end

  ARRAY_FORM = /^\w+\[\]$/
  HASH_FORM = /^\w+(\[\w+\])+$/
  def params_that_presented_multiple_times
    cgi_params = CGI.parse(query_string)
    cgi_params.reject! { |_k, v| v.length == 1 }
    cgi_params.reject! { |k, _v| k =~ ARRAY_FORM }
    cgi_params.reject! { |k, _v| k =~ HASH_FORM }
    cgi_params.reduce({}) do |result, (key, value)|
      result[key] = formatted_value(key, value)
      result
    end
  end
end
