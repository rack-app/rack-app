module Rack::App::Test::Utils

  extend self

  def format_properties(properties)
    raise('use hash format such as params: {"key" => "value"} or headers with the same concept') unless properties.is_a?(Hash)
    properties[:params] ||= {}
    properties[:headers]||= {}

    properties
  end

  def env_by(properties)

    properties = format_properties(properties)
    env = properties[:headers].reduce({}) { |m, (k, v)| m.merge("HTTP_#{k.to_s.tr('-', '_').upcase}" => v.to_s) }
    payload = properties.delete(:payload)
    env["rack.input"]= ::Rack::Lint::InputWrapper.new(string_io_for(payload))
    env[::Rack::QUERY_STRING]= Rack::App::Utils.encode_www_form(properties[:params].to_a)
    env.merge!(properties[:env] || {})

    env
  end

  def string_io_for(payload)
    case payload

      when IO
        payload

      when String
        StringIO.new(payload.to_s)

      else
        StringIO.new('')

    end
  end

end
