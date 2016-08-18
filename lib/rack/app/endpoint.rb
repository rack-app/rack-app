require "rack/builder"
class Rack::App::Endpoint
  require "rack/app/endpoint/properties"
  require "rack/app/endpoint/executor"

  def properties
    @properties.to_hash
  end

  def initialize(properties)
    @properties = Rack::App::Endpoint::Properties.new(properties)
  end

  def call(env)
    to_app.call(env)
  end

  def to_app
    builder = Rack::Builder.new
    apply_middleware_build_blocks(builder)
    @properties.endpoint_method_name
    builder.run(Rack::App::Endpoint::Executor.new(@properties))
    builder.to_app
  end

  protected

  def apply_middleware_build_blocks(builder)
    builder_blocks.each do |builder_block|
      builder_block.call(builder)
    end
    builder.use(Rack::App::Middlewares::Configuration, @properties.app_class)
    apply_hook_middlewares(builder)
  end

  def apply_hook_middlewares(builder)
    @properties.app_class.before.each do |before_block|
      builder.use(Rack::App::Middlewares::Hooks::Before, before_block)
    end
    @properties.app_class.after.each do |after_block|
      builder.use(Rack::App::Middlewares::Hooks::After, after_block)
    end
  end

  def builder_blocks
    @properties.app_class.middlewares + @properties.middleware_builders_blocks
  end

end
