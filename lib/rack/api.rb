require 'rack'
require 'rack/request'
require 'rack/response'
class Rack::API

  require 'rack/api/version'

  require 'rack/api/syntax_sugar'
  extend Rack::API::SyntaxSugar

  attr_reader :request, :response

  def initialize(request, response)
    @response = response
    @request = request
  end

end