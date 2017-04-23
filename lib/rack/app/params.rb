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

  def formatted_value(key, value)
    single_paramter_value?(value) && !key.end_with?("[]") ? value[0] : value
  end

  #
  # Converts an array value to a string
  #
  # @example:
  # array_value_to_string('a[][b]', [2, 3])
  # => "a[][b]=2&a[][b]=3"
  #
  def array_value_to_string(key, value)
    value.to_a.map { |val| "#{key}=#{val}" }.join('&')
  end

  def single_paramter_value?(v)
    v.is_a?(Array) and v.length === 1
  end

  def raw_cgi_params
    CGI.parse(@env[::Rack::QUERY_STRING])
  end

  def raw_rack_formatted_params
    cgi_params  = raw_cgi_params
    regexp      = /\[|%5B/
    well_formed = cgi_params.select { |k,v| !k.match(regexp) }.reduce({}) { |o, (k, v)| o[k] = formatted_value(k,v); o }
    reformated  = cgi_params.select { |k, value| k.match(regexp) }.map { |k, v| (v.to_s.match(regexp).nil? ? v : array_value_to_string(k, v)) }.join('&')
    parsed      = Rack::Utils.parse_nested_query reformated

    well_formed.merge(parsed)
  end

end
