class Rack::App::Endpoint

  require "forwardable"
  extend Forwardable
  def_delegators :@config, :request_method, :request_path, :description

  require "rack/app/endpoint/config"
  require "rack/app/endpoint/builder"
  require "rack/app/endpoint/catcher"
  require "rack/app/endpoint/executor"

  attr_reader :config

  def initialize(properties)
    @config = Rack::App::Endpoint::Config.new(properties)
  end

  def fork(differences_in_properties)
    self.class.new(self.properties.merge(differences_in_properties))
  end

  def properties
    @config.to_hash
  end

  def call(env)
    to_app.call(env)
  end

  def to_app
    # TODO: fix this to cache it, but to that you need to resolve the problem when middlewares added,
    # old endpoints are not refreshed by the middleware configs
    # router.reset must be checked
    self.class::Builder.new(@config).to_app
  end

  def rack_app?
    !!@config.app_class
  rescue
    false
  end

end
