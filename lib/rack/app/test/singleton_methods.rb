module Rack::App::Test::SingletonMethods

  def rack_app(*args, &constructor)
    in_this_context(:__rack_app_args__) { args }
    in_this_context(:__rack_app_constructor__) { constructor }
    in_this_context(:rack_app) do
      Rack::App::Test::Utils.rack_app_by(*__rack_app_args__, &__rack_app_constructor__)
    end
    nil
  end

  def in_this_context(name, &block)
    let(name, &block)
  rescue NoMethodError
    define_method(name, &block)
  end

end