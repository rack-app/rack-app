module Rack::App::Test::SingletonMethods

  def rack_app(rack_app_class=nil, &constructor)
    klass = if !rack_app_class.nil? && rack_app_class.respond_to?(:call)
      rack_app_class
    else
      Class.new(Rack::App)
    end

    klass.class_eval(&constructor) unless constructor.nil?
    return in_this_context(:__rack_app_class__){ klass }
  end

  def in_this_context(name, &block)
    let(name, &block)
  rescue NoMethodError
    define_method(name, &block)
  end

end
