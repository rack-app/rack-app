class Rack::App::Handlers < ::Hash
  attr_reader :env, :request, :response

  def initialize(env, request, response)
    @env = env
    @request = request
    @response = response
  end

  def get(klass)
    self[klass] ||= klass.new.tap do |h|
      h.env = @env
      h.request = @request
      h.response = @response
    end
  end
end