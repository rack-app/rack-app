module Rack::App::Test::SingletonMethods

  def rack_app(rack_app_class=nil, &constructor)
    in_this_context(:__rack_app_class__) { rack_app_class }
    in_this_context(:__rack_app_constructor__) { constructor }
    nil
  end

  def in_this_context(name, &block)
    let(name, &block)
  rescue NoMethodError
    define_method(name, &block)
  end

end