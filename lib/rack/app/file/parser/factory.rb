module Rack::App::File::Parser::Factory

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