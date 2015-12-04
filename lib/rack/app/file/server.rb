class Rack::App::File::Server < Rack::App

  class << self

    def source_folder(relative_folder_path)

      source_folder = Rack::App::Utils.pwd(relative_folder_path)
      Dir.glob(File.join(source_folder, '**', '*')).each do |file_path|

        file_parser_class = find_file_parser_class_for(File.extname(file_path))

        raw_endpoint_name = file_path.sub(source_folder, '').split(File::Separator).join('/')
        request_path = file_parser_class.format_request_path(raw_endpoint_name)

        options request_path do
          response.finish
        end

        get request_path do
          file_parser = file_parser_class.new(self)

          response.body = file_parser.parse(file_path)
          response.headers[Rack::CONTENT_TYPE]= Rack::Mime.mime_type(file_parser.file_type(file_path)).to_s

          response.finish
        end

      end

    end

    def use_file_parser(parser_class, *extensions)
      extensions.each do |extension|
        file_parser_classes[extension.to_s]= parser_class
      end
      nil
    end

    def find_file_parser_class_for(extension)
      file_parser_classes[extension.to_s] || Rack::App::File::Parser
    end

    protected

    def file_parser_classes
      @file_parser_classes ||= {
          '.erb' => Rack::App::File::Parser::ERB
      }
    end

  end

end