module Rack::App::Constants

  require "rack/app/constants/http_status_codes"

  def self.rack_constant(constant_name, fallback_value)
    ::Rack.const_get(constant_name)
  rescue NameError
    fallback_value.freeze
  end

  module HTTP

    module METHOD
      ANY     = 'ANY'.freeze
      GET     = 'GET'.freeze
      POST    = 'POST'.freeze
      PUT     = 'PUT'.freeze
      PATCH   = 'PATCH'.freeze
      DELETE  = 'DELETE'.freeze
      HEAD    = 'HEAD'.freeze
      OPTIONS = 'OPTIONS'.freeze
      LINK    = 'LINK'.freeze
      UNLINK  = 'UNLINK'.freeze
      TRACE   = 'TRACE'.freeze
    end

    METHODS = (METHOD.constants - [:ANY]).map(&:to_s).freeze

    module Headers
      CONTENT_TYPE = "Content-Type".freeze
    end

  end

  module ENV

    PATH_INFO = Rack::App::Constants.rack_constant(:PATH_INFO, "PATH_INFO")
    REQUEST_PATH = Rack::App::Constants.rack_constant(:REQUEST_PATH, "REQUEST_PATH")
    REQUEST_METHOD = Rack::App::Constants.rack_constant(:REQUEST_METHOD, "REQUEST_METHOD")

    EXTNAME = 'rack-app.extname'.freeze
    SERIALIZER = 'rack-app.serializer'.freeze
    CONTENT_TYPE = 'CONTENT_TYPE'.freeze
    REQUEST_HANDLER = 'rack-app.handler'.freeze

    PARAMS_GETTER = 'rack-app.params.getter'
    PARSED_PARAMS = 'rack-app.params.parsed'.freeze
    VALIDATED_PARAMS = 'rack-app.params.validated'.freeze

    PAYLOAD_PARSER = 'rack-app.payload.parser'.freeze
    PAYLOAD_GETTER = 'rack-app.payload.getter'.freeze
    PARSED_PAYLOAD = 'rack-app.payload.parsed'.freeze

    ORIGINAL_PATH_INFO = 'rack-app.original_path_info'.freeze
    PATH_PARAMS_MATCHER = 'rack-app.path_params_matcher'.freeze
    METHODOVERRIDE_ORIGINAL_METHOD = 'rack-app.methodoverride.original_method'.freeze

  end

  MOUNTED_DIRECTORY = '[Mounted Directory]'.freeze
  RACK_BASED_APPLICATION = '[Mounted Rack Application]'.freeze

end
