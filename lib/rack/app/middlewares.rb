module Rack::App::Middlewares
  require 'rack/app/middlewares/payload_parser_setter'
  require 'rack/app/middlewares/path_info_cutter'
  require 'rack/app/middlewares/configuration'
  require 'rack/app/middlewares/header_setter'
  require 'rack/app/middlewares/params'
  require 'rack/app/middlewares/hooks'
end
