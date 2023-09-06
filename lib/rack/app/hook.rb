class Rack::App::Hook

  attr_accessor :Class, :block

  def initialize(options = {}, &block)
    self.Class = options[:class] || raise(ArgumentError, "missing :class keyword argument")
    self.block = block
  end

  def exec(env)
    env[Rack::App::Constants::ENV::HANDLERS].get(self.Class).instance_exec(&self.block)
  end

end
