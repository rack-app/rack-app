class Rack::App::Payload::Parser::Builder

  require "rack/app/payload/parser/builder/formats"

  def initialize
    @content_type__parsers = Hash.new(Rack::App::Payload::Parser::DEFAULT_PARSER)
  end

  def to_parser
    Rack::App::Payload::Parser.new(@content_type__parsers.dup)
  end

  def on(content_type, &parser)
    @content_type__parsers[content_type]= parser
    self
  end

  def accept(*formats)
    Rack::App::Payload::Parser::Builder::Formats.accept(self, *formats)
  end

  def on_unsupported_media_types(&parser)
    @content_type__parsers = Hash.new(parser).merge(@content_type__parsers)
  end

  def reject_unsupported_media_types
    reject = proc do |io|
      rr = Rack::Response.new
      rr.status = 415
      rr.write("Unsupported Media Type")
      rr.write("Accepted content-types:")
      @content_type__parsers.each do |content_type, _|
        rr.write(content_type.to_s)
      end
      throw(:rack_response, rr)
    end
    @content_type__parsers = Hash.new(reject).merge(@content_type__parsers)
    nil
  end

  def merge!(parser_builder)
    raise unless parser_builder.is_a?(self.class)
    @content_type__parsers.merge!(parser_builder.instance_variable_get(:@content_type__parsers))
    self
  end

end
