# frozen_string_literal: true

require 'rack/builder'
class Rack::App::Endpoint::Builder
  def initialize(config)
    @config = config
  end

  def to_app
    build.to_app
  end

  protected

  def build
    builder = Rack::Builder.new
    apply_middleware_build_blocks(builder)
    builder.run(app)
    builder
  end

  def app
    case @config.type
    when :endpoint
      Rack::App::Endpoint::Executor.new(@config)
    else
      @config.callable
    end
  end

  def apply_middleware_build_blocks(builder)
    @config.middlewares.each do |builder_block|
      builder.instance_exec(builder, &builder_block)
    end
    builder.use(Rack::App::Middlewares::Configuration, @config)

    apply_catcher_on_need(builder)
    @config.ancestor_apps.reverse_each do |app_class|
      apply_hook_middlewares(app_class, builder)
    end
  end

  def apply_catcher_on_need(builder)
    at_least_one_hook_requested = @config.ancestor_apps.any? do |app_class|
      app_class.before.length + app_class.after.length > 0
    end

    if at_least_one_hook_requested
      builder.use(Rack::App::Endpoint::Catcher, @config)
    end
  end

  def apply_hook_middlewares(app_class, builder)
    app_class.before.each do |before_block|
      builder.use(Rack::App::Middlewares::Hooks::Before, before_block)
    end

    app_class.after.each do |after_block|
      builder.use(Rack::App::Middlewares::Hooks::After, after_block)
    end
  end
end
