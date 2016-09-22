module Rack::App::Constants

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
      CONTENT_TYPE = Rack::App::Constants.rack_constant(:CONTENT_TYPE, "Content-Type")
    end

  end

  module ENV

    PATH_INFO = Rack::App::Constants.rack_constant(:PATH_INFO, "PATH_INFO")
    REQUEST_PATH = Rack::App::Constants.rack_constant(:REQUEST_PATH, "REQUEST_PATH")
    REQUEST_METHOD = Rack::App::Constants.rack_constant(:REQUEST_METHOD, "REQUEST_METHOD")

    EXTNAME = 'rack-app.extname'.freeze
    REQUEST_HANDLER = 'rack-app.handler'
    SERIALIZER = 'rack-app.serializer'
    PARSED_PARAMS = 'rack-app.parsed_params'
    VALIDATED_PARAMS = 'rack-app.validated_params'
    ORIGINAL_PATH_INFO = 'rack-app.original_path_info'.freeze
    PATH_PARAMS_MATCHER = 'rack-app.path_params_matcher'.freeze
    METHODOVERRIDE_ORIGINAL_METHOD = 'rack-app.methodoverride.original_method'.freeze
  end

  MOUNTED_DIRECTORY = '[Mounted Directory]'.freeze
  RACK_BASED_APPLICATION = '[Mounted Rack Application]'.freeze

end
