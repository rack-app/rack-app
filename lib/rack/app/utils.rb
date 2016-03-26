require 'securerandom'
module Rack::App::Utils
  extend self

  require 'rack/app/utils/deep_dup'

  # Normalizes URI path.
  #
  # Strips off trailing slash and ensures there is a leading slash.
  #
  #   normalize_path("/foo")  # => "/foo"
  #   normalize_path("/foo/") # => "/foo"
  #   normalize_path("foo")   # => "/foo"
  #   normalize_path("")      # => "/"
  def normalize_path(path)
    path = "/#{path}"
    path.squeeze!('/')
    path.sub!(%r{/+\Z}, '')
    path = '/' if path == ''
    path
  end

  # Based on ActiveSupport, removed inflections.
  # https://github.com/rails/rails/blob/v4.1.0.rc1/activesupport/lib/active_support/inflector/methods.rb
  def underscore(camel_cased_word)
    word = camel_cased_word.to_s.gsub('::', '/')
    word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
    word.tr!("-", "_")
    word.downcase!
    word
  end

  def pwd(*path_parts)

    root_folder = if ENV['BUNDLE_GEMFILE']
                    ENV['BUNDLE_GEMFILE'].split(File::Separator)[0..-2].join(File::Separator)
                  else
                    Dir.pwd.to_s
                  end

    return File.join(root_folder, *path_parts)

  end

  def uuid
    ary = SecureRandom.random_bytes(16).unpack("NnnnnN")
    ary[2] = (ary[2] & 0x0fff) | 0x4000
    ary[3] = (ary[3] & 0x3fff) | 0x8000
    "%08x-%04x-%04x-%04x-%04x%08x" % ary
  end

  def join(*url_path_parts)
    url_path_parts = [url_path_parts].flatten.compact
    File.join(*url_path_parts).gsub(File::Separator, '/').sub(/^\/?(.*)$/, '/\1')
  end

  def expand_path(file_path)
    case file_path

      when /^\.\//
        File.expand_path(File.join(File.dirname(caller[1]), file_path))

      when /^[^\/]/
        File.join(namespace_folder(caller[1]), file_path)

      when /^\//
        from_project_root_path = pwd(file_path)
        File.exist?(from_project_root_path) ? from_project_root_path : file_path

    end
  end

  def namespace_folder(file_path_info)
    basename = File.basename(file_path_info).split('.')[0]
    directory = File.dirname(file_path_info)
    File.join(directory,basename)
  end


  def deep_dup(object)
    ::Rack::App::Utils::DeepDup.new(object).to_dup
  end

end