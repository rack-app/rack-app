module Rack::App::InstanceMethods

  require 'rack/app/instance_methods/core'
  require 'rack/app/instance_methods/params'
  require 'rack/app/instance_methods/http_status'
  require 'rack/app/instance_methods/redirect_to'
  require 'rack/app/instance_methods/path_to'
  require 'rack/app/instance_methods/payload'
  require 'rack/app/instance_methods/serve_file'
  require 'rack/app/instance_methods/streaming'

  include Rack::App::InstanceMethods::Core
  include Rack::App::InstanceMethods::Params
  include Rack::App::InstanceMethods::HTTPStatus
  include Rack::App::InstanceMethods::RedirectTo
  include Rack::App::InstanceMethods::PathTo
  include Rack::App::InstanceMethods::Payload
  include Rack::App::InstanceMethods::ServeFile
  include Rack::App::InstanceMethods::Streaming

end
