require 'rack'
require 'rack/request'
require 'rack/response'
class Rack::APP

  require 'rack/app/version'

  require 'rack/app/utils'
  require 'rack/app/router'
  require 'rack/app/endpoint'
  require 'rack/app/endpoint/not_found'
  require 'rack/app/runner'

  require 'rack/app/class_methods'
  extend Rack::APP::ClassMethods

  require 'rack/app/request_helpers'

  include Rack::APP::RequestHelpers

  def self.call(request_env)
    Rack::APP::Runner.response_for(self,request_env)
  end

  attr_reader :request, :response

  protected

  def initialize(request, response)
    @response = response
    @request = request
  end

end