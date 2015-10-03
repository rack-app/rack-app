require 'rack'
require 'rack/request'
require 'rack/response'
class Rack::API

  require 'rack/api/version'

  require 'rack/api/syntax_sugar'
  extend Rack::API::SyntaxSugar

end