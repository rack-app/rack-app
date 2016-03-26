module Rack::App::Constants

  module HTTP
    ANY = 'ANY'.freeze
    GET='GET'.freeze
    POST = 'POST'.freeze
    PUT = 'PUT'.freeze
    DELETE = 'DELETE'.freeze
    PATCH = 'PATCH'.freeze
    HEAD = 'HEAD'.freeze
    OPTIONS = 'OPTIONS'.freeze
  end

  NORMALIZED_PATH_INFO = 'rack-app.path_info'.freeze
  PATH_PARAMS_MATCHER = 'rack-app.path_params_matcher'.freeze
  RACK_BASED_APPLICATION = '[Mounted Rack Application]'.freeze

end