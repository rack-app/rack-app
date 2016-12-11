class Rack::App::Payload::Parser::Builder

  require "rack/app/payload/parser/builder/defaults"

  def initialize
    @parsers = {}
  end

  def to_parser
    Rack::App::Payload::Parser.new(@parsers)
  end

  def on(content_type, &parser)
    @parsers[content_type]= parser
    self
  end

  FORMS = {
    :json => Rack::App::Payload::Parser::Builder::Defaults.method(:json),
    :form => Rack::App::Payload::Parser::Builder::Defaults.method(:form),
    :urlencoded => Rack::App::Payload::Parser::Builder::Defaults.method(:form),
    :www_form_urlencoded => Rack::App::Payload::Parser::Builder::Defaults.method(:form)
  }

  def accept(*form_names)
    form_names.map(&:to_sym).each do |form_name|
      (FORMS[form_name] || raise(NotImplementedError)).call(self)
    end
  end

  def merge!(parser_builder)
    raise unless parser_builder.is_a?(self.class)
    @parsers.merge!(parser_builder.instance_variable_get(:@parsers))
    self
  end

end
