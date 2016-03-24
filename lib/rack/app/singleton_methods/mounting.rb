module Rack::App::SingletonMethods::Mounting

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

  def mount_directory(directory_path, options={})

    directory_full_path = Rack::App::Utils.expand_path(directory_path)

    namespace options[:to] do

      Dir.glob(File.join(directory_full_path, '**', '*')).each do |file_path|

        request_path = file_path.sub(/^#{Regexp.escape(directory_full_path)}/, '')
        get(request_path){ serve_file(file_path) }
        options(request_path){ '' }

      end

    end
    nil

  end

  alias create_endpoints_for_files_in mount_directory

  def serve_files_from(file_path, options={})
    file_server = Rack::App::FileServer.new(Rack::App::Utils.expand_path(file_path))
    request_path = Rack::App::Utils.join(@namespaces, options[:to], '**', '*')
    router.register_endpoint!('GET', request_path, @last_description, file_server)
    @last_description = nil
  end

  protected

  def on_mounted(&block)
    @on_mounted ||= []
    @on_mounted << block unless block.nil?
    @on_mounted
  end

  alias while_being_mounted on_mounted

end
