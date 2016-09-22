class Rack::App::Serializer::FormatsBuilder

  def initialize
    @formatters = {}
    @content_types = {}
    @default_formatter = lambda { |o| o.to_s }
    @default_content_type = nil
  end

  def on(extname, response_content_type, &formatter)
    format = String(extname).downcase
    extension = (format[0] == '.' ? format : ".#{format}")
    @formatters[extension]= formatter
    @content_types[extension]= response_content_type
    self
  end

  def default(content_type=nil, &block)
    @default_content_type = content_type if content_type
    @default_formatter = block if block
    self
  end

  def to_serializer
    Rack::App::Serializer.new(
      :formatters => @formatters,
      :content_types => @content_types,
      :default_formatter => @default_formatter,
      :default_content_type => @default_content_type
    )
  end

  def merge!(formats_builder)
    @formatters.merge!(formats_builder.instance_variable_get(:@formatters))
    @default_formatter = formats_builder.instance_variable_get(:@default_formatter)
    self
  end

end
