# frozen_string_literal: true
require 'rack/builder'
class Rack::App::Endpoint::Builder
  def initialize(config)
    @config = config
  end

  def build
    builder = Rack::Builder.new
    apply_middleware_build_blocks(builder)
    builder.run(app)
    builder.to_app
  end

  protected

  def app
    case @config.type
    when :endpoint
      Rack::App::Endpoint::Executor.new(@config)
    else
      @config.callable
    end
  end

  def apply_middleware_build_blocks(builder)
    builder_blocks.each do |builder_block|
      builder_block.call(builder)
    end
    builder.use(Rack::App::Middlewares::Configuration, @config)

    apply_hook_middlewares(builder)
  end

  def apply_hook_middlewares(builder)
    if @config.app_class.before.length + @config.app_class.after.length > 0
      builder.use(Rack::App::Endpoint::Catcher, @config)
    end
    @config.app_class.before.each do |before_block|
      builder.use(Rack::App::Middlewares::Hooks::Before, before_block)
    end
    @config.app_class.after.each do |after_block|
      builder.use(Rack::App::Middlewares::Hooks::After, after_block)
    end
  end

  def builder_blocks
    [@config.app_class.middlewares, @config.endpoint_specific_middlewares].flatten
  end
end
