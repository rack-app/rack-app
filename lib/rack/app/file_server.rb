class Rack::App::FileServer

  def initialize(root_folder)
    require 'rack/file'
    @root_folder = root_folder
    @relative_file_paths = Dir.glob(File.join(@root_folder, '**', '*')).map { |file_path| file_path.sub(@root_folder, '') }.sort_by { |str| str.length }.reverse
    @rack_file_server = ::Rack::File.new(@root_folder, {})
  end

  def call(env)
    path_info = clean_path_info(env)

    @relative_file_paths.each do |relative_file_path|
      if path_info =~ /#{Regexp.escape(relative_file_path)}$/
        env[::Rack::PATH_INFO]= relative_file_path
        break
      end
    end

    @rack_file_server.call(env)
  end

  def self.serve_file(env, file_path)
    file_server = self.new(File.dirname(file_path))
    env = env.dup
    env[::Rack::REQUEST_METHOD]= 'GET'
    env[::Rack::PATH_INFO]= file_path
    file_server.call(env)
  end

  protected

  def clean_path_info(env)
    path_info = ::Rack::Utils.unescape(env[::Rack::PATH_INFO])
    ::Rack::Utils.clean_path_info(path_info)
  end

end
