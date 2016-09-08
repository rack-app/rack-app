class Rack::App::Endpoint

  require "forwardable"
  extend Forwardable
  def_delegators :@config, :request_method, :request_path, :description

  require "rack/app/endpoint/config"
  require "rack/app/endpoint/builder"
  require "rack/app/endpoint/executor"

  attr_reader :config

  def initialize(properties)
    @application = properties.delete(:application)
    @config = Rack::App::Endpoint::Config.new(properties)
  end

  def properties
    @config.to_hash
  end

  def call(env)
    to_app.call(env)
  end

  def to_app
    @application || self.class::Builder.new(@config).build
  end

end
