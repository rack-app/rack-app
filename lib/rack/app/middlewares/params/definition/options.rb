class Rack::App::Middlewares::Params::Definition::Options

  ERROR_EACH = 'class must implement #each method to use :of expression in parameter definition'

  def initialize(descriptor)
    @descriptor = descriptor
  end

  def formatted
    {
      class: parameter_class,
      of: parameter_class_elements
    }
  end

  protected

  def parameter_class
    @descriptor[:class] || @descriptor[:type]
  end

  def parameter_class_elements
    if @descriptor[:of]
      raise "#{parameter_class} #{ERROR_EACH}" unless parameter_class_iterable?
      @descriptor[:of]
    end
  end

  def parameter_class_iterable?
    parameter_class.instance_methods.include?(:each)
  end

end
