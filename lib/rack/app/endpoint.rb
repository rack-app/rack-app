class Rack::App::Endpoint

  require "forwardable"
  extend Forwardable
  def_delegators :@config, :request_method, :request_path, :description

  require "rack/app/endpoint/config"
  require "rack/app/endpoint/builder"
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

  def supported_extnames
    @config.serializer.extnames
  end

  def request_paths
    @config.serializer.extnames.map do |extname|
      @config.request_path + extname
    end.push(@config.request_path)
  end

  def to_app
    @config.application || self.class::Builder.new(@config).build
  end

end
