module Rack::App::InstanceMethods::Payload

  def payload_stream(&block)
    return nil unless @request.body.respond_to?(:gets)
    while chunk = request.body.gets
      block.call(chunk)
    end
    request.body.rewind
    nil
  end

  def payload
    request.env[Rack::App::Constants::ENV::PARSED_PAYLOAD] ||= lambda do
      request.env[Rack::App::Constants::ENV::PAYLOAD_PARSER].parse_env(request.env)
    end.call
  end

  def payload_to_file(file_path, file_mod='w')
    File.open(file_path, file_mod) do |file|
      payload_stream { |chunk| file.print(chunk) }
    end
  end

end
