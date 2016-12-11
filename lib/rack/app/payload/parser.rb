require 'stringio'
require 'rack/request'
class Rack::App::Payload::Parser
  require 'rack/app/payload/parser/builder'

  DEFAULT_PARSER = proc { |io| io.read }

  def initialize(content_type__parsers = {})
    raise unless content_type__parsers.is_a?(Hash)
    @content_type__parsers = Hash.new(DEFAULT_PARSER)
    @content_type__parsers.merge!(content_type__parsers)
  end

  def parse_io(content_type, io)
    @content_type__parsers[content_type.to_s].call(io)
  end

  def parse_env(env)
    request = Rack::Request.new(env)
    parse_io(request.content_type, request.body)
  end

  def parse_string(content_type, str)
    parse_io(content_type, StringIO.new(str))
  end
end
