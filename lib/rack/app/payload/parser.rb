require 'stringio'
require 'rack/request'
class Rack::App::Payload::Parser
  require 'rack/app/payload/parser/builder'

  DEFAULT_PARSER = proc { |io| io.read }

  def initialize(content_type__parsers = {})
    raise unless content_type__parsers.is_a?(Hash)
    @content_type__parsers = content_type__parsers
  end

  def parse_io(content_type, content_length, io)
    parser_for(content_type.to_s).call(io, content_type, content_length.to_i)
  end

  def parse_env(env)
    request = Rack::Request.new(env)

    parse_io(request.content_type, request.content_length, request.body)
  end

  def parse_string(content_type, str)
    parse_io(content_type, StringIO.new(str))
  end

  protected

  def parser_for(content_type)
    @content_type__parsers[without_boundary(content_type)] || DEFAULT_PARSER
  end

  def without_boundary(content_type)
    content_type.split(';').first
  end
end
