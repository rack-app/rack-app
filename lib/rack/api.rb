require 'rack'
require 'rack/request'
require 'rack/response'
class Rack::API

  require 'rack/api/version'

  require 'rack/api/endpoint'
  require 'rack/api/endpoint/not_found'

  require 'rack/api/runner'

  require 'rack/api/syntax_sugar'
  extend Rack::API::SyntaxSugar

  require 'rack/api/request_helpers'
  include Rack::API::RequestHelpers

  attr_reader :request, :response

  def initialize(request, response)
    @response = response
    @request = request
  end

  def self.call(request_env)
    Rack::API::Runner.response_for(self,request_env)
  end

end