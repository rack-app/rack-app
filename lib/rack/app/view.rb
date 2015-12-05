class Rack::App::View

  extend Rack::App::File::Parser::Factory

  def render(view_file_basename)
    file_path = File.join(class_current_folder, view_file_basename)
    self.class.find_file_parser_class_for(File.extname(file_path)).new(self).parse(file_path).to_a.join("\n")
  end

  def class_current_folder
    method(:call).source_location.first.sub(/.rb$/,'')
  end

end