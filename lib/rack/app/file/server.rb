class Rack::App::File::Server

  def initialize(root_folder, options={})
    require 'rack/file'

    namespace = formatted_namespace(options)
    namespace.freeze

    @namespace_rgx = /#{Regexp.escape(namespace)}/.freeze
    @rack_file_server = ::Rack::File.new(Rack::App::Utils.pwd(root_folder), {})

  end

  def call(env)
    env[::Rack::PATH_INFO]= clean_path_info(env).sub(@namespace_rgx, '')
    @rack_file_server.call(env)
  end

  protected

  def raw_namespace(options)
    options[:to] || '/'
  end

  def formatted_namespace(options)
    namespace = raw_namespace(options).to_s.sub(/^\//, '').sub(/\/$/, '')
    namespace += '/' unless namespace.empty?
    namespace
  end

  def clean_path_info(env)
    path_info = ::Rack::Utils.unescape(env[::Rack::PATH_INFO])
    return clean_path_info = ::Rack::Utils.clean_path_info(path_info)
  end

end