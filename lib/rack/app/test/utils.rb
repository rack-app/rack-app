module Rack::App::Test::Utils

  extend self

  def format_properties(properties)
    raise('use hash format such as params: {"key" => "value"} or headers with the same concept') unless properties.is_a?(Hash)
    properties[:params] ||= {}
    properties[:headers]||= {}

    properties
  end

  def rack_app_by(subject_class, constructors, &block)

    app_class = subject_class.respond_to?(:call) ? subject_class : Rack::App
    app = Rack::App::Utils.deep_dup(app_class)
    constructors.each { |constructor| app.class_eval(&constructor) }

    return app
  end

  def env_by(properties)

    properties = format_properties(properties)
    env = properties[:headers].reduce({}) { |m, (k, v)| m.merge("HTTP_#{k.to_s.gsub('-', '_').upcase}" => v.to_s) }
    payload = properties.delete(:payload)
    env["rack.input"]= ::Rack::Lint::InputWrapper.new(string_io_for(payload))
    env[::Rack::QUERY_STRING]= encode_www_form(properties[:params].to_a)
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

  def encode_www_form(enum)
    enum.map do |k, v|
      if v.nil?
        encode_www_form_component(k)
      elsif v.respond_to?(:to_ary)
        v.to_ary.map do |w|
          str = encode_www_form_component(k)
          unless w.nil?
            str << '='
            str << encode_www_form_component(w)
          end
        end.join('&')
      else
        str = encode_www_form_component(k)
        str << '='
        str << encode_www_form_component(v)
      end
    end.join('&')
  end

  TBLENCWWWCOMP_ = {} # :nodoc:
  256.times do |i|
    TBLENCWWWCOMP_['%%%02X' % i] = i.chr
  end
  TBLENCWWWCOMP_[' '] = '+'
  TBLENCWWWCOMP_.freeze
  TBLDECWWWCOMP = {} # :nodoc:
  256.times do |i|
    h, l = i>>4, i&15
    TBLDECWWWCOMP[i.chr]= '%%%X%X' % [h, l]
    TBLDECWWWCOMP[i.chr]= '%%%X%X' % [h, l]
    TBLDECWWWCOMP[i.chr]= '%%%x%X' % [h, l]
    TBLDECWWWCOMP[i.chr]= '%%%X%x' % [h, l]
    TBLDECWWWCOMP[i.chr]= '%%%x%x' % [h, l]
  end
  TBLDECWWWCOMP['+'] = ' '
  TBLDECWWWCOMP.freeze

  def encode_www_form_component(str)
    str = str.to_s.dup
    TBLENCWWWCOMP_.each do |from, to|
      str.gsub!(from, to)
    end
    str
  end

end
