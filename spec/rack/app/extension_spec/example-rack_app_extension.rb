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

  includes ExampleExtensionEndpointMethods

  extends ExampleExtensionClassMethods

  extend_application_inheritance_with do |parent, child|

    def child.hello
      'world'
    end

  end

end
