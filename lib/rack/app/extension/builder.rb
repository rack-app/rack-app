class Rack::App::Extension::Builder

  def initialize(&builder_block)
    instance_exec(&builder_block)
  end

  def includes(*modules)
    @includes ||= []
    @includes.push(*modules) unless modules.empty?
    @includes
  end

  def extends(*modules)
    @extends ||= []
    @extends.push(*modules) unless modules.empty?
    @extends
  end

  def inheritances
    @inheritances ||= []
  end

  def on_inheritance(&block)
    inheritances << block
  end

  alias extend_application_inheritance_with on_inheritance

end