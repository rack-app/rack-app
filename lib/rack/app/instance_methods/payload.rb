module Rack::App::InstanceMethods::Payload

  def payload_stream(&block)
    return nil unless @request.body.respond_to?(:gets)
    parser = request.env[Rack::App::Constants::ENV::PAYLOAD_PARSER]
    content_type = request.content_type
    while chunk = request.body.gets
      block.call(parser.parse_string(content_type, chunk))
    end
    request.body.rewind
    nil
  end

  def payload
    request.env[Rack::App::Constants::ENV::PAYLOAD_GETTER].call
  end

  def payload_to_file(file_path, file_mod='w')
    return nil unless @request.body.respond_to?(:gets)
    File.open(file_path, file_mod) do |file|
      while chunk = request.body.gets
        file.print(chunk)
      end
    end
  end

end
