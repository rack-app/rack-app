class Rack::App::File::Parser

  require 'rack/app/file/parser/factory'
  require 'rack/app/file/parser/erb'

  def self.format_request_path(request_path)
    request_path
  end

  def parse(file_path)
    Rack::App::File::Streamer.new(file_path)
  end

  def file_type(file_path)
    File.extname(file_path)
  end

  protected

  def initialize(app)
    @app = app
  end

end