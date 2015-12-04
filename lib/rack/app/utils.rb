module Rack::App::Utils
  extend self

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

  def pwd(*path_parts)

    root_folder =if ENV['BUNDLE_GEMFILE']
                   ENV['BUNDLE_GEMFILE'].split(File::Separator)[0..-2].join(File::Separator)
                 else
                   Dir.pwd.to_s
                 end

    return File.join(root_folder,*path_parts)

  end

end