module Example
  class RackAppExtension < Rack::App::Extension

    module ClassMethods

      def hello
        'hello world'
      end

    end

    module EndpointMethods

      def sup
        'all good thanks!'
      end

    end

    include EndpointMethods

    extend ClassMethods

    on_inheritance do |parent, child|

      def child.hello
        'world'
      end

    end

  end
end