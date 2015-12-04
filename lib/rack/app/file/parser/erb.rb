require 'erb'
class Rack::App::File::Parser::ERB < Rack::App::File::Parser

  require 'erb'

  def parse(file_path)
    [::ERB.new(File.read(file_path)).result(@app.instance_eval { binding })]
  end

  def file_type(file_path)
    super(file_path.sub(/\.erb$/, ''))
  end

  def self.format_request_path(request_path)
    request_path.sub(/\.erb$/, '')
  end

end