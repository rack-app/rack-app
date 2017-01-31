module Rack::App::SingletonMethods::Mounting
  MOUNT = Rack::App::SingletonMethods::Mounting

  def mount(app, options={})
    case
    when app.is_a?(Class) && app < ::Rack::App
      mount_rack_app(app, options)
    when app.respond_to?(:call)
      mount_rack_interface_compatible_application(app, options)
    else
      raise(NotImplementedError)
    end
  end

  def mount_rack_app(app, options={})
    options.freeze

    unless app.is_a?(Class) and app <= Rack::App
      raise(ArgumentError, 'Invalid class given for mount, must be a Rack::App')
    end

    cli.merge!(app.cli)
    merge_prop = {:namespaces => [@namespaces, options[:to]].flatten}
    router.merge_router!(app.router, merge_prop)

    nil
  end

  def mount_directory(directory_path, options={})

    directory_full_path = ::Rack::App::Utils.expand_path(directory_path)

    namespace options[:to] do

      Dir.glob(File.join(directory_full_path, '**', '*')).each do |file_path|

        request_path = file_path.sub(/^#{Regexp.escape(directory_full_path)}/, '')
        get(request_path) { serve_file(file_path) }
        options(request_path) { '' }

      end

    end
    nil

  end

  alias create_endpoints_for_files_in mount_directory
  Rack::App::Utils.deprecate(self,:create_endpoints_for_files_in, :mount_directory, 2016,9)

  def serve_files_from(file_path, options={})
    file_server = Rack::App::FileServer.new(Rack::App::Utils.expand_path(file_path))
    request_path = Rack::App::Utils.join(@namespaces, options[:to], '**', '*')

    endpoint = Rack::App::Endpoint.new(
      route_registration_properties.merge(
        :request_methods => [
          Rack::App::Constants::HTTP::METHOD::GET,
          Rack::App::Constants::HTTP::METHOD::OPTIONS
        ],
        :request_path => request_path,
        :application => file_server
      )
    )

    router.register_endpoint!(endpoint)
    route_registration_properties.clear
    nil
  end

  def mount_rack_interface_compatible_application(rack_based_app, options={})
    properties = route_registration_properties.merge(
          :request_methods => ::Rack::App::Constants::HTTP::METHOD::ANY,
          :request_path => Rack::App::Utils.join(
            @namespaces,
            options[:to],
            ::Rack::App::Constants::RACK_BASED_APPLICATION
          ),
          :application => rack_based_app
    )

    router.register_endpoint!(Rack::App::Endpoint.new(properties))
  end

end
