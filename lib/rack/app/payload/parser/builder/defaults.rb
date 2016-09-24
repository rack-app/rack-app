module Rack::App::Payload::Parser::Builder::Defaults
  extend(self)

  def apply(builder)
    form(builder)
    json(builder)
    csv(builder)
    yaml(builder)
  end

  protected

  YAML_CONTENT_TYPE = [
    "text/yaml",
    "text/x-yaml",
    "application/yaml",
    "application/x-yaml",
  ]

  YAML_PARSER = proc do |io|
    YAML.load(io.read)
  end

  def yaml(builder)
    require "yaml"
    YAML_CONTENT_TYPE.each do |content_type|
      builder.on(content_type, &YAML_PARSER)
    end
  rescue LoadError
  end

  JSON_CONTENT_TYPE = [
    "application/json",
    "application/x-javascript",
    "text/javascript",
    "text/x-javascript",
    "text/x-json",
  ]

  JSON_PARSER = proc do |io|
    JSON.load(io)
  end

  def json(builder)
    require "json"
    JSON_CONTENT_TYPE.each do |content_type|
      builder.on(content_type, &JSON_PARSER)
    end
  rescue LoadError
  end

  CSV_CONTENT_TYPE = [
    "text/comma-separated-values",
    "application/csv",
    "text/csv",
  ]

  CSV_PARSER = proc do |io|
    CSV.parse(io.read)
  end

  def csv(builder)
    require "csv"
    CSV_CONTENT_TYPE.each do |content_type|
      builder.on(content_type, &CSV_PARSER)
    end
  rescue LoadError
  end

  FORM_CONTENT_TYPES = [
    'application/x-www-form-urlencoded',
    # 'multipart/form-data'
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

  def form(builder)
    FORM_CONTENT_TYPES.each do |content_type|
      builder.on(content_type, &FORM_PARSER)
    end
  end

end
