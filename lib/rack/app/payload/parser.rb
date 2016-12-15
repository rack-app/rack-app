require 'stringio'
require 'rack/request'
class Rack::App::Payload::Parser
  require 'rack/app/payload/parser/builder'

  def initialize(content_type__parsers = {})
    raise unless content_type__parsers.is_a?(Hash)
    @content_type__parsers = content_type__parsers
  end

  def parse_io(content_type, io)
    parser_for(content_type.to_s).call(io)
  end

  def parse_env(env)
    request = Rack::Request.new(env)
    parse_io(request.content_type, request.body)
  end

  def parse_string(content_type, str)
    parse_io(content_type, StringIO.new(str))
  end

  protected

  def parser_for(content_type)
    @content_type__parsers[content_type] || Rack::App::Payload::Parser::Builder::DEFAULT_PARSER
  end

end
