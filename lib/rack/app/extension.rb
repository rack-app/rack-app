class Rack::App::Extension

  require 'rack/app/extension/factory'

  class << self

    def names
      @names ||= []
    end

    def name(extension_name_alias)
      names << extension_name_alias.to_s.to_sym
    end

    def inherited(klass)
      klass.name(Rack::App::Utils.snake_case(klass.to_s.split('::').last).to_sym)
    end

    def includes
      @includes ||= []
    end

    def extends
      @extends ||= []
    end

    def inheritances
      @on_inheritances ||= []
    end

    def include(endpoint_methods_module)
      includes << endpoint_methods_module
    end

    def extend(app_class_methods_module)
      extends << app_class_methods_module
    end

    def on_inheritance(&block)
      inheritances << block
    end

  end
end