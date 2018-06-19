module Rack::App::Payload::Parser::Builder::Formats
  extend(self)

  JSON_CONTENT_TYPES = [
    'application/json',
    'application/x-javascript',
    'text/javascript',
    'text/x-javascript',
    'text/x-json'
  ].freeze

  JSON_PARSER = proc do |io|
    begin
      ::JSON.load(io)
    rescue ::JSON::ParserError => ex
      rr = Rack::Response.new
      rr.status = 400
      rr.write(ex.message)
      throw(:rack_response, rr)
    end
  end

  def json(builder)
    require 'json'
    JSON_CONTENT_TYPES.each do |content_type|
      builder.on(content_type, &JSON_PARSER)
    end
  end

  JSON_STREAM_CONTENT_TYPES = [
    'application/jsonstream',
    'application/stream+json',
    'application/x-json-stream'
  ].freeze

  JSON_STREAM_PARSER = proc do |io|
    Rack::App::RequestStream.new(io, JSON_PARSER)
  end

  def json_stream(builder)
    JSON_STREAM_CONTENT_TYPES.each do |content_type|
      builder.on(content_type, &JSON_STREAM_PARSER)
    end
  end

  # CSV_CONTENT_TYPE = [
  #   "text/comma-separated-values",
  #   "application/csv",
  #   "text/csv",
  # ]
  #
  # CSV_PARSER = proc do |io|
  #   CSV.parse(io.read)
  # end
  #
  # def csv(builder)
  #   require "csv"
  #   CSV_CONTENT_TYPE.each do |content_type|
  #     builder.on(content_type, &CSV_PARSER)
  #   end
  # rescue LoadError
  # end

  FORM_CONTENT_TYPES = [
    'application/x-www-form-urlencoded',
  ].freeze

  FORM_SEP_CHAR = '&'.freeze

  RACK_QUERY_PARSER = if Rack::Utils.respond_to?(:default_query_parser)
                        lambda do |form|
                          ::Rack::Utils.default_query_parser.parse_nested_query(form, FORM_SEP_CHAR)
                        end
                      else
                        lambda do |form|
                          ::Rack::Utils.parse_nested_query(form, FORM_SEP_CHAR)
                        end
  end

  NULL_END_CHAR = /#{"\u0000"}$/

  FORM_PARSER = proc do |io|
    form_vars = io.read
    # Fix for Safari Ajax postings that always append \0
    form_vars.slice!(NULL_END_CHAR)
    RACK_QUERY_PARSER.call(form_vars)
  end

  def www_form_urlencoded(builder)
    FORM_CONTENT_TYPES.each do |content_type|
      builder.on(content_type, &FORM_PARSER)
    end
  end

  alias form www_form_urlencoded
  alias urlencoded www_form_urlencoded

  MULTIPART_CONTENT_TYPES = 'multipart/form-data'.freeze

  MULTIPART_PARSER = proc do |io, content_type, content_length|
    tempfile = Rack::Multipart::Parser::TEMPFILE_FACTORY
    bufsize = Rack::Multipart::Parser::BUFSIZE
    query_parser = Rack::Utils.default_query_parser
    multipart_struct = Rack::Multipart::Parser.parse(
      io, content_length, content_type, tempfile, bufsize, query_parser
    )
    multipart_struct.params
  end

  def multipart(builder)
    builder.on(MULTIPART_CONTENT_TYPES, &MULTIPART_PARSER)
  end

  def accept(builder, *form_names)
    last_name = nil
    form_names.map(&:to_sym).each do |form_name|
      last_name = form_name
      unless respond_to?(form_name)
        raise(NotImplementedError, "unknown formatter: #{last_name}")
      end
      __send__ form_name, builder
    end
  end
end
