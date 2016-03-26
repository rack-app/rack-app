class Rack::App::Extension
  class << self

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