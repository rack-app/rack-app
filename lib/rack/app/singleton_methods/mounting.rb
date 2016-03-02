module Rack::App::SingletonMethods::Mounting

  def on_mounted(&block)
    @on_mounted ||= []
    @on_mounted << block unless block.nil?
    @on_mounted
  end

  alias while_being_mounted on_mounted

  def mount(api_class, mount_prop={})

    unless api_class.is_a?(Class) and api_class <= Rack::App
      raise(ArgumentError, 'Invalid class given for mount, must be a Rack::App')
    end

    api_class.on_mounted.each do |on_mount|
      on_mount.call(self, mount_prop)
    end

    merge_prop = {:namespaces => [@namespaces, mount_prop[:to]].flatten}
    router.merge_router!(api_class.router, merge_prop)

    return nil
  end

end
