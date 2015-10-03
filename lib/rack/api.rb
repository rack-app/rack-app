require 'rack'
require 'rack/request'
require 'rack/response'
class Rack::API

  require 'rack/api/version'

  require 'rack/api/syntax_sugar'
  extend Rack::API::SyntaxSugar

  require 'rack/api/request_helpers'
  include Rack::API::RequestHelpers

  attr_reader :request, :response

  def initialize(request, response)
    @response = response
    @request = request
  end

  def request_path_not_found
    response.status= 404
    response.write '404 Not Found'
    response.finish
  end

end