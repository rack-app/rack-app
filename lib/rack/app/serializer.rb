class Rack::App::Serializer

  require "rack/app/serializer/formats_builder"

  def initialize(options={})

    @default_formatter = options[:default_formatter] || lambda { |o| o.to_s }
    @default_content_type = options[:default_content_type]

    formatters = options[:formatters] || {}
    content_types = options[:content_types] || {}

    @content_types = Hash.new(@default_content_type)
    @content_types.merge!(content_types)

    @formatters = Hash.new(@default_formatter)
    @formatters.merge!(formatters)

  end

  def serialize(extname, object)
    String(@formatters[extname].call(object))
  end

  CONTENT_TYPE = ::Rack::App::Constants::HTTP::Headers::CONTENT_TYPE

  def response_headers_for(extname)
    headers = {}
    add_content_type_for(headers, extname)
    headers
  end

  def to_options
    {
      :formatters => @formatters,
      :content_types => @content_types,
      :default_formatter => @default_formatter,
      :default_content_type => @default_content_type,
    }
  end

  def extnames
    (@formatters.keys + @content_types.keys).uniq
  end

  protected

  def add_content_type_for(headers, extname)
    content_type = @content_types[extname]
    if content_type
      headers[CONTENT_TYPE]= content_type.dup
    end
  end


end
