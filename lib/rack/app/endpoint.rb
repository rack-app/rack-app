require "rack/builder"
class Rack::App::Endpoint

  require "rack/app/endpoint/config"
  require "rack/app/endpoint/builder"
  require "rack/app/endpoint/executor"

  def initialize(properties)
    @config = Rack::App::Endpoint::Config.new(properties)
  end

  def properties
    @config.to_hash
  end

  def call(env)
    to_app.call(env)
  end

  def to_app
    self.class::Builder.new(@config).build
  end

end
