class Rack::App::Middlewares::Params::Definition

  require "rack/app/middlewares/params/definition/options"

  def initialize(&descriptor)
    @required = {}
    @optional = {}
    instance_exec(&descriptor)
  end

  def required(params_key,options)
    @required[params_key.to_s]= self.class::Options.new(options).formatted
  end

  def optional(params_key,options)
    @optional[params_key.to_s]= self.class::Options.new(options).formatted
  end

  def to_descriptor
    {:required => @required, :optional => @optional}
  end
end
