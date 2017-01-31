# frozen_string_literal: true
class Rack::App::Endpoint::Config
  def to_hash
    error_handler
    middleware_builders_blocks
    request_path
    request_methods
    defined_request_path
    @raw
  end

  def payload_builder
    @raw[:payload].parser_builder
  end

  def application
    @raw[:application]
  end

  def app_class
    @raw[:app_class] || raise('missing app class')
  end

  def serializer
    serializer_builder.to_serializer
  end

  def payload
    app_class.__send__(:payload)
  end

  def payload_parser
    payload.parser.to_parser
  end

  def serializer_builder
    @raw[:serializer_builder] ||= app_class.__send__(:formats)
  end

  def error_handler
    @raw[:error_handler] ||= Rack::App::ErrorHandler.new
  end

  def middleware_builders_blocks
    @raw[:middleware_builders_blocks] ||= []
  end

  def endpoint_method_name
    @raw[:method_name] ||= register_method_to_app_class
  end

  def request_methods
    case @raw[:request_methods] || raise('missing config: request_methods')
    when Rack::App::Constants::HTTP::METHOD::ANY
      Rack::App::Constants::HTTP::METHODS
    when ::Array
      @raw[:request_methods].map(&:to_sym)
    else
      [@raw[:request_methods]].flatten.map(&:to_sym)
    end
  end

  def request_path
    Rack::App::Utils.normalize_path(@raw[:request_path] || raise('missing request_path!'))
  end

  def defined_request_path
    Rack::App::Utils.normalize_path(@raw[:defined_request_path] ||= request_path)
  end

  def description
    @raw[:route][:description] || @raw[:route][:desc]
  rescue
    nil
  end

  protected

  def initialize(raw)
    @raw = raw
  end

  def register_method_to_app_class
    method_name = '__' + ::Rack::App::Utils.uuid
    app_class.__send__(:define_method, method_name, &logic_block)
    method_name
  end

  def logic_block
    @raw[:user_defined_logic]
  end
end
