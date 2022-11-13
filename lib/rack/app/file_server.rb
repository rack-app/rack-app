class Rack::App::FileServer
  attr_accessor :relative_file_paths

  def self.serve_file(env, file_path)
    dir_path = File.dirname(file_path)
    basename = File.basename(file_path)
    file_server = new(dir_path, map_relative_file_paths: false)
    env = env.dup
    env[::Rack::App::Constants::ENV::REQUEST_METHOD] = 'GET'
    env[::Rack::App::Constants::ENV::PATH_INFO] = basename
    file_server.call(env)
  end

  def initialize(root_folder, opts = {})
    @root_folder = root_folder
    @relative_file_paths = []
    @rack_file_server = ::Rack::Files.new(@root_folder, {})

    if map_relative_file_paths?(opts)
      map_relative_paths!
    end
  end

  def call(env)
    path_info = clean_path_info(env)

    @relative_file_paths.each do |relative_file_path|
      if path_info =~ /#{Regexp.escape(relative_file_path)}$/
        env[::Rack::App::Constants::ENV::PATH_INFO] = relative_file_path
        break
      end
    end

    @rack_file_server.call(env)
  end

  protected

  def map_relative_file_paths?(opts = {})
    unless opts.key?(:map_relative_file_paths)
      return true
    end

    opts[:map_relative_file_paths]
  end

  def opts_set_defaults(opts)
    unless opts.key?(:map_relative_file_paths)
      opts[:map_relative_file_paths] = true
    end
  end

  def map_relative_paths!
    @relative_file_paths = Dir.glob(File.join(@root_folder, '**', '*'))
                               .map { |file_path| file_path.sub(@root_folder, '') }
                               .sort_by { |str| str.length }
                               .reverse
  end

  def clean_path_info(env)
    path_info = ::Rack::Utils.unescape(env[::Rack::App::Constants::ENV::PATH_INFO])
    ::Rack::Utils.clean_path_info(path_info)
  end
end
