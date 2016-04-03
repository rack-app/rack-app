module ExampleExtensionClassMethods
  def hello
    'hello world'
  end
end

module ExampleExtensionEndpointMethods
  def sup
    'all good thanks!'
  end
end

Rack::App::Extension.register('rack_app_extension') do

  include ExampleExtensionEndpointMethods
  extend ExampleExtensionClassMethods

  on_inheritance do |parent, child|

    def child.hello
      'world'
    end

  end

end