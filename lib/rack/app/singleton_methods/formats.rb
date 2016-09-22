module Rack::App::SingletonMethods::Formats

  def formats(&descriptor)
    @formats_builder ||= Rack::App::Serializer::FormatsBuilder.new
    unless descriptor.nil?
      @formats_builder.instance_exec(&descriptor)
      router.reset 
    end
    @formats_builder
  end

  def serializer(default_content_type=nil, &how_to_serialize)
    formats{ default(default_content_type,&how_to_serialize) } unless how_to_serialize.nil?
    return formats.to_serializer
  end

end
