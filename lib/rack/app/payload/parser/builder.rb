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

  def accept_json
    Rack::App::Payload::Parser::Builder::Defaults.json(self)
  end

  def accept_www_form_urlencoded
    Rack::App::Payload::Parser::Builder::Defaults.form(self)
  end

  def merge!(parser_builder)
    raise unless parser_builder.is_a?(self.class)
    @parsers.merge!(parser_builder.instance_variable_get(:@parsers))
    self
  end

end
