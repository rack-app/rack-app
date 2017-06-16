# frozen_string_literal: true
class Rack::App::Endpoint::Config

  def to_hash
    error_handler
    endpoint_specific_middlewares
    request_path
    request_method
    defined_request_path
    @raw
  end

  def callable
    @raw[:callable]
  end

  def type
    case callable
    when ::Rack::App::Block
      :endpoint
    else
      :application
    end
  end

  def payload_builder
    @raw[:payload].parser_builder
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

  def endpoint_specific_middlewares
    @raw[:endpoint_specific_middlewares] ||= []
  end

  def request_method
    @raw[:request_method] || raise('missing config: request_methods')
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

  def logic_block
    @raw[:user_defined_logic]
  end
end
